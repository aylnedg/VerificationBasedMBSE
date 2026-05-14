function av_param_check(~)
% AirVehicle Performance Bounds — SLDD parameter assertion
% Verifies that QuadData.sldd values satisfy design-to-spec requirements.
% Linked requirements: uav #2-7, sys #12-17

dd  = Simulink.data.dictionary.open('QuadData.sldd');
sec = getSection(dd, 'Design Data');

UAVmass_val  = getValue(getEntry(sec, 'UAVmass'));
g_val        = getValue(getEntry(sec, 'g'));
landTime_val = getValue(getEntry(sec, 'landTime'));

assert(UAVmass_val <= 5, ...
    sprintf('FAIL uav:#13/sys:#22-23 — UAVmass=%.4f kg exceeds 5 kg spec', UAVmass_val));

assert(abs(g_val - 9.81) < 0.001, ...
    sprintf('FAIL internal — g=%.5f must equal 9.81 m/s^2', g_val));

assert(landTime_val > 0, ...
    sprintf('FAIL uav:#16 — landTime=%.4f must be positive (landing capability present)', landTime_val));
end
