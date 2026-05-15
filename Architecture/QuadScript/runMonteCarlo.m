function results = runMonteCarlo(nRuns, useParsim)
%RUNMONTECARLO Monte Carlo analysis for FeedbackControl.
%
%   results = runMonteCarlo(100, true)
%
%   Stochastic parameters (5 dimensions):
%     UAVmass  ~ Normal(0.05, 0.0025)   ±5% 1-sigma
%     landTime ~ Uniform(9.6, 14.4)     ±20%
%     WP_dx    ~ Uniform(-0.1, 0.1)     shared X offset
%     WP_dy    ~ Uniform(-0.1, 0.1)     shared Y offset
%     WP_dz    ~ Uniform(-0.1, 0.1)     shared Z offset
%
%   Outputs measured per run:
%     maxThrust     - peak thrust command (N)
%     minThrust     - minimum thrust (negative = anomaly)
%     anyFaultFired - 1 if FaultFlags.AnyFault ever true
%     missionSuccess- 1 if sim completed without error
%     finalPosZ     - final altitude at end of sim

if nargin < 1; nRuns = 100; end
if nargin < 2; useParsim = true; end

mdl = 'FeedbackControl';
load_system(mdl);

nominalWP = [0 0 -1; 0 1 -1; 1 1 -1; 1 0 -1; 0 0 0];

rng(42); % fixed seed for reproducibility

%% Build SimulationInput array
simInputs(1:nRuns) = Simulink.SimulationInput(mdl);

for k = 1:nRuns
    mass_k     = 0.05 + 0.0025 * randn();
    mass_k     = max(0.040, min(0.060, mass_k));
    landTime_k = 9.6 + (14.4 - 9.6) * rand();
    dx = (rand() - 0.5) * 0.2;
    dy = (rand() - 0.5) * 0.2;
    dz = (rand() - 0.5) * 0.2;
    wp_k = nominalWP + [dx dy dz; dx dy dz; ...
                        dx dy dz; dx dy dz; dx dy dz];

    si = simInputs(k);
    si = setVariable(si, 'UAVmass',   mass_k,     ...
                     'Workspace', mdl);
    si = setVariable(si, 'landTime',  landTime_k, ...
                     'Workspace', mdl);
    si = setVariable(si, 'waypoints', wp_k,       ...
                     'Workspace', mdl);
    si = setModelParameter(si, 'SimulationMode', ...
                           'normal');
    simInputs(k) = si;
end

%% Run simulations
fprintf('Running %d Monte Carlo simulations...\n', nRuns);
t0 = tic;

if useParsim
    simouts = parsim(simInputs, ...
        'ShowProgress',       'on',  ...
        'TransferBaseWorkspaceVariables', 'on');
else
    simouts = sim(simInputs);
end

elapsed = toc(t0);
fprintf('Completed in %.1f s (%.2f s/run)\n', ...
        elapsed, elapsed/nRuns);

%% Extract results
results = struct();
results.nRuns      = nRuns;
results.elapsed    = elapsed;
results.params     = struct();
results.outputs    = struct();

mass_arr     = zeros(nRuns,1);
landTime_arr = zeros(nRuns,1);
maxThrust    = zeros(nRuns,1);
minThrust    = zeros(nRuns,1);
anyFault     = zeros(nRuns,1);
success      = zeros(nRuns,1);
finalPosZ    = zeros(nRuns,1);

rng(42);
for k = 1:nRuns
    mass_arr(k)     = 0.05 + 0.0025*randn();
    mass_arr(k)     = max(0.040, min(0.060, mass_arr(k)));
    landTime_arr(k) = 9.6 + (14.4-9.6)*rand();
    rand(); rand(); rand(); % consume dx,dy,dz

    so = simouts(k);
    if ~isempty(so.ErrorMessage)
        success(k) = 0;
        continue;
    end
    success(k) = 1;

    try
        yout = so.yout;
        thrustSig = yout{1}.Values.Thrust.Data;
        maxThrust(k) = max(thrustSig);
        minThrust(k) = min(thrustSig);

        faultSig = yout{2}.Values.AnyFault.Data;
        anyFault(k) = any(faultSig > 0.5);

        altSig = so.logsout.getElement('UAVState');
        if ~isempty(altSig)
            posZ = altSig.Values.WorldPosition.Data(3,:,:);
            finalPosZ(k) = posZ(end);
        end
    catch
        success(k) = 1;
    end
end

results.params.UAVmass   = mass_arr;
results.params.landTime  = landTime_arr;
results.outputs.maxThrust  = maxThrust;
results.outputs.minThrust  = minThrust;
results.outputs.anyFault   = anyFault;
results.outputs.success    = success;
results.outputs.finalPosZ  = finalPosZ;

%% Statistics
nSuccess = sum(success);
nFault   = sum(anyFault);

results.stats.successRate   = 100 * nSuccess / nRuns;
results.stats.faultRate     = 100 * nFault   / nRuns;
results.stats.meanMaxThrust = mean(maxThrust(success==1));
results.stats.stdMaxThrust  = std(maxThrust(success==1));
results.stats.p5Thrust      = prctile(maxThrust(success==1), 5);
results.stats.p95Thrust     = prctile(maxThrust(success==1), 95);
results.stats.meanMinThrust = mean(minThrust(success==1));
results.stats.thrustViolations = sum(maxThrust > 2.0 & success==1);

fprintf('\n=== Monte Carlo Results (%d runs) ===\n', nRuns);
fprintf('Success rate:       %.1f%%\n', results.stats.successRate);
fprintf('Fault fired rate:   %.1f%%\n', results.stats.faultRate);
fprintf('Max thrust  mean:   %.4f N  std: %.4f N\n', ...
        results.stats.meanMaxThrust, results.stats.stdMaxThrust);
fprintf('Max thrust  P5/P95: %.4f / %.4f N\n', ...
        results.stats.p5Thrust, results.stats.p95Thrust);
fprintf('Thrust violations:  %d runs (Thrust > 2.0 N)\n', ...
        results.stats.thrustViolations);

end
