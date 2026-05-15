function runWithQGC(scenario, qgcIP, qgcPort)
%RUNWITHQGC Run UAV simulation with live QGC telemetry.
%
%   runWithQGC('nominal', '127.0.0.1', 14550)
%
%   Sends HEARTBEAT (1 Hz) and GLOBAL_POSITION_INT (4 Hz)
%   to QGroundControl via MAVLink UDP during simulation.

if nargin < 1; scenario = 'nominal'; end
if nargin < 2; qgcIP    = '127.0.0.1'; end
if nargin < 3; qgcPort  = 14550; end

%% Setup
projRoot = 'C:/UAV/VerificationBasedMBSE';
cd(projRoot)

switch scenario
  case 'nominal'
    setVariantConfig('Nominal_MAVLink')
    stopT   = 30;
    missionTitle = 'Nominal MAVLink — Waypoint Mission';
    baseLat =  39.9040;
    baseLon =  32.8630;
    baseAlt =  900.0;

  case 'adversarial'
    setVariantConfig('Adversarial_MAVLink')
    stopT   = 20;
    missionTitle = 'Adversarial — MAVLink Spoof at t=7s';
    baseLat =  39.9045;
    baseLon =  32.8635;
    baseAlt =  900.0;

  case 'search_rescue'
    setVariantConfig('Nominal_MAVLink')
    stopT   = 45;
    missionTitle = 'Search and Rescue — Extended Pattern';
    baseLat =  39.9035;
    baseLon =  32.8625;
    baseAlt =  900.0;
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

%% Shared state (use containers.Map for mutability across timer callbacks)
sharedPos = containers.Map({'x','y','z'},{0.0, 0.0, 0.0});

%% Scale factors
latScale = 1 / 111320;
lonScale = 1 / (111320 * cosd(baseLat));

%% Timer for telemetry at 4 Hz
tmr = timer('ExecutionMode', 'fixedRate', ...
            'Period',        0.25, ...
            'TimerFcn', @(t,e) sendTelemetry(mav, dialect, ...
                sharedPos, qgcIP, qgcPort, ...
                baseLat, baseLon, baseAlt));
start(tmr)

%% Run simulation
fprintf('Starting simulation...\n')
open_system('QuadArchitecture')

try
  simOut = sim('QuadArchitecture', 'StopTime', num2str(stopT));

  % Update sharedPos from logsout after sim
  try
    ls = simOut.logsout;
    wpSig = ls{3}.Values;            % <WorldPosition> [3x1xT]
    wpData = squeeze(wpSig.Data);    % [3xT]
    finalPos = wpData(:,end);
    sharedPos('x') = finalPos(1);
    sharedPos('y') = finalPos(2);
    sharedPos('z') = finalPos(3);
    fprintf('Final NED: x=%.3f  y=%.3f  z=%.3f m\n', ...
            finalPos(1), finalPos(2), finalPos(3))
  catch
  end
  fprintf('Mission complete.\n')

catch ME
  fprintf('Simulation error: %s\n', ME.message)
end

%% Cleanup
stop(tmr)
delete(tmr)
if ~isempty(mav)
  disconnect(mav)
  fprintf('MAVLink UDP disconnected.\n')
end

end

%% Timer callback
function sendTelemetry(mav, dialect, sharedPos, qgcIP, qgcPort, ...
                       baseLat, baseLon, baseAlt)
if isempty(mav); return; end

persistent tCount
if isempty(tCount); tCount = uint32(0); end
tCount = tCount + uint32(1);
tBoot  = tCount * uint32(250);   % ms since start

x = sharedPos('x');
y = sharedPos('y');
z = sharedPos('z');

latDeg = baseLat + x / 111320;
lonDeg = baseLon + y / (111320 * cosd(baseLat));
altM   = baseAlt - z;

%% HEARTBEAT
try
  hb = createmsg(dialect, 'HEARTBEAT');
  hb.Payload.type            = uint8(2);    % MAV_TYPE_QUADROTOR
  hb.Payload.autopilot       = uint8(8);    % MAV_AUTOPILOT_INVALID
  hb.Payload.base_mode       = uint8(209);  % armed + guided + custom
  hb.Payload.system_status   = uint8(4);    % MAV_STATE_ACTIVE
  hb.Payload.mavlink_version = uint8(3);
  hb.Payload.custom_mode     = uint32(0);
  sendudpmsg(mav, hb, qgcIP, qgcPort)
catch
end

%% GLOBAL_POSITION_INT
try
  gpi = createmsg(dialect, 'GLOBAL_POSITION_INT');
  gpi.Payload.time_boot_ms = tBoot;
  gpi.Payload.lat          = int32(latDeg * 1e7);
  gpi.Payload.lon          = int32(lonDeg * 1e7);
  gpi.Payload.alt          = int32(altM   * 1000);
  gpi.Payload.relative_alt = int32(-z     * 1000);
  gpi.Payload.vx           = int16(0);
  gpi.Payload.vy           = int16(0);
  gpi.Payload.vz           = int16(0);
  gpi.Payload.hdg          = uint16(0);
  sendudpmsg(mav, gpi, qgcIP, qgcPort)
catch
end

%% ATTITUDE
try
  at = createmsg(dialect, 'ATTITUDE');
  at.Payload.time_boot_ms = tBoot;
  at.Payload.roll         = single(0);
  at.Payload.pitch        = single(0);
  at.Payload.yaw          = single(0);
  at.Payload.rollspeed    = single(0);
  at.Payload.pitchspeed   = single(0);
  at.Payload.yawspeed     = single(0);
  sendudpmsg(mav, at, qgcIP, qgcPort)
catch
end

end
