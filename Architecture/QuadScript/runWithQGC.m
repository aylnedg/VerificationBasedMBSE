function runWithQGC(scenario, qgcIP, qgcPort)
%RUNWITHQGC Run UAV simulation with live QGC telemetry.
%
%   runWithQGC('nominal', '127.0.0.1', 14550)
%
%   Phase A: runs simulation silently (fast).
%   Phase B: replays logged WorldPosition to QGC at real-time speed,
%            so the operator sees smooth vehicle movement on the map.

if nargin < 1; scenario = 'nominal'; end
if nargin < 2; qgcIP    = '127.0.0.1'; end
if nargin < 3; qgcPort  = 14550; end

%% Scenario configuration
projRoot = 'C:/UAV/VerificationBasedMBSE';
cd(projRoot)

switch scenario
  case 'nominal'
    setVariantConfig('Nominal_MAVLink')
    stopT        = 30;
    missionTitle = 'Nominal MAVLink — Waypoint Mission';
    baseLat      =  39.9040;
    baseLon      =  32.8630;
    baseAlt      =  900.0;
    mapScale     =  1;

  case 'adversarial'
    setVariantConfig('Adversarial_MAVLink')
    stopT        = 20;
    missionTitle = 'Adversarial — MAVLink Spoof at t=7s';
    baseLat      =  39.9045;
    baseLon      =  32.8635;
    baseAlt      =  900.0;
    mapScale     =  1;

  case 'search_rescue'
    setVariantConfig('Nominal_MAVLink')
    stopT        = 45;
    missionTitle = 'Search and Rescue — Extended Pattern';
    baseLat      =  39.9035;
    baseLon      =  32.8625;
    baseAlt      =  900.0;
    mapScale     =  100;   % multiply NED displacement for QGC visibility
    sarWP = [0 0 -1; 0 2 -1; 2 2 -1; 2 0 -1; 1 1 -1.5; 0 0 0];
    dd  = Simulink.data.dictionary.open(...
      'Architecture/QuadData/QuadData.sldd');
    sec = getSection(dd,'Design Data');
    setValue(getEntry(sec,'waypoints'), sarWP(1:5,:));
    saveChanges(dd);

  otherwise
    error('Unknown scenario: %s', scenario)
end

fprintf('\n=== %s ===\n', missionTitle)
fprintf('QGC target: %s:%d\n', qgcIP, qgcPort)

%% Open MAVLink UDP connection
commonXML = fullfile(matlabroot,'toolbox','uav','uavmatlab',...
    'mavlink','message_definitions','common.xml');
dialect = mavlinkdialect(commonXML);
mav     = mavlinkio(dialect);

try
  connect(mav, 'UDP', 'LocalPort', 14560);
  fprintf('MAVLink UDP connected (local:14560 -> %s:%d)\n', qgcIP, qgcPort)
catch ME
  warning('UDP connect failed: %s', ME.message)
  mav = [];
end

%% PHASE A — Run simulation silently
fprintf('Phase A: running simulation (StopTime=%ds)...\n', stopT)
open_system('QuadArchitecture')

simOut = sim('QuadArchitecture', 'StopTime', num2str(stopT));
fprintf('Phase A complete.\n')

%% Extract WorldPosition timeseries
try
  wpSig    = simOut.logsout.getElement('WorldPosition');
  posData  = squeeze(wpSig.Values.Data);   % [3 x N]
  timeData = wpSig.Values.Time;            % [N x 1]
  fprintf('Extracted %d telemetry frames (%.1fs).\n', ...
    length(timeData), timeData(end))
catch ME
  fprintf('Could not extract WorldPosition: %s\n', ME.message)
  if ~isempty(mav); disconnect(mav); end
  return
end

%% PHASE B — Replay to QGC at real-time speed
fprintf('Phase B: replaying %d frames to QGC...\n', length(timeData))

latDeg = baseLat;
lonDeg = baseLon;
altM   = baseAlt;

tStart = tic;
for k = 1:length(timeData)
  targetT = timeData(k);

  % Wait until wall-clock matches sim time
  while toc(tStart) < targetT
    pause(0.01)
  end

  posNED = posData(:, k);

  latDeg = baseLat + posNED(1) * mapScale * (1 / 111320);
  lonDeg = baseLon + posNED(2) * mapScale * (1 / (111320 * cosd(baseLat)));
  altM   = baseAlt + posNED(3) * mapScale;

  %% GLOBAL_POSITION_INT
  try
    gpi = createmsg(dialect, 'GLOBAL_POSITION_INT');
    gpi.Payload.time_boot_ms = uint32(targetT * 1000);
    gpi.Payload.lat          = int32(latDeg * 1e7);
    gpi.Payload.lon          = int32(lonDeg * 1e7);
    gpi.Payload.alt          = int32(altM   * 1000);
    gpi.Payload.relative_alt = int32(-posNED(3) * 1000);

    if k > 1
      dt  = max(timeData(k) - timeData(k-1), 0.001);
      vel = (posData(:,k) - posData(:,k-1)) / dt;
      gpi.Payload.vx = int16(vel(1) * 100);  % cm/s North
      gpi.Payload.vy = int16(vel(2) * 100);  % cm/s East
      gpi.Payload.vz = int16(vel(3) * 100);  % cm/s Down
      if norm(vel(1:2)) > 0.1
        heading = atan2(vel(2), vel(1)) * 180 / pi;
        if heading < 0; heading = heading + 360; end
        gpi.Payload.hdg = uint16(heading * 100);
      else
        gpi.Payload.hdg = uint16(0);
      end
    else
      gpi.Payload.vx  = int16(0);
      gpi.Payload.vy  = int16(0);
      gpi.Payload.vz  = int16(0);
      gpi.Payload.hdg = uint16(0);
    end

    sendudpmsg(mav, gpi, qgcIP, qgcPort)
  catch
  end

  %% HEARTBEAT every ~1 s (every 10th frame at ~10 Hz log rate)
  if mod(k, 10) == 1
    try
      hb = createmsg(dialect, 'HEARTBEAT');
      hb.Payload.type            = uint8(2);
      hb.Payload.autopilot       = uint8(8);
      hb.Payload.base_mode       = uint8(209);
      hb.Payload.system_status   = uint8(4);
      hb.Payload.mavlink_version = uint8(3);
      hb.Payload.custom_mode     = uint32(0);
      sendudpmsg(mav, hb, qgcIP, qgcPort)
    catch
    end
  end
end

fprintf('Replay complete. Final position: lat=%.6f, lon=%.6f, alt=%.1fm\n', ...
  latDeg, lonDeg, altM)
fprintf('Final NED: x=%.3f  y=%.3f  z=%.3f m\n', ...
  posData(1,end), posData(2,end), posData(3,end))

%% Cleanup
if ~isempty(mav)
  disconnect(mav)
  fprintf('MAVLink UDP disconnected.\n')
end

end
