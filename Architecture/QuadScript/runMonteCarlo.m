%RUNMONTECARLO 100-run Monte Carlo analysis for FeedbackControl.
% Perturbs UAVmass (±5%), landTime (±20%), waypoints (±0.1 m per axis).
% Results saved to Verification/reports/montecarlo_results.mat.

rng(42);
N = 100;
model = 'FeedbackControl';
load_system(model);

%% Nominal parameter values
UAVmass_nom  = 0.05;
landTime_nom = 12;
WP_nom       = [0 0 -1; 2 0 -1; 5 5 -1; 2 2 -1; 0 0 -0.5];

%% Sample perturbations
UAVmass_samples  = UAVmass_nom  * (1 + 0.05 * randn(N,1));
landTime_samples = landTime_nom * (1 + 0.20 * (rand(N,1) - 0.5) * 2);
WP_offsets       = 0.1 * (rand(N,3) - 0.5) * 2;  % shared per-axis offset per run

%% Build SimulationInput array
simInputs(1:N) = Simulink.SimulationInput(model);
for i = 1:N
    si = Simulink.SimulationInput(model);
    si = setVariable(si, 'UAVmass',  UAVmass_samples(i),  'Workspace', model);
    si = setVariable(si, 'landTime', landTime_samples(i), 'Workspace', model);
    wp_i = WP_nom + repmat(WP_offsets(i,:), 5, 1);
    si = setVariable(si, 'waypoints', wp_i, 'Workspace', model);
    simInputs(i) = si;
end

%% Run simulations
tStart = tic;
try
    simOutputs = parsim(simInputs, 'ShowProgress', 'on', ...
                        'TransferBaseWorkspaceVariables', 'off');
catch ME
    warning('parsim failed (%s), falling back to serial sim.', ME.message);
    simOutputs = sim(simInputs);
end
wallTime = toc(tStart);
fprintf('Monte Carlo: %d runs completed in %.1f s\n', N, wallTime);

%% Extract results
max_thrust      = zeros(N,1);
fault_triggered = false(N,1);
crashed         = false(N,1);

for i = 1:N
    try
        if ~isempty(simOutputs(i).ErrorMessage)
            crashed(i) = true;
            continue;
        end
        yout = simOutputs(i).yout;
        % Port 1 = Control (struct with Thrust etc.), Port 2 = FaultFlags
        ctrl = yout{1}.Values;
        if isstruct(ctrl)
            thrust_ts = ctrl.Thrust;
        else
            thrust_ts = ctrl;
        end
        if isa(thrust_ts, 'timeseries')
            max_thrust(i) = max(abs(thrust_ts.Data(:)));
        else
            max_thrust(i) = max(abs(double(thrust_ts(:))));
        end
        faults = yout{2}.Values;
        if isa(faults, 'timeseries')
            fault_triggered(i) = any(faults.Data(:) ~= 0);
        else
            fault_triggered(i) = any(double(faults(:)) ~= 0);
        end
    catch
        crashed(i) = true;
    end
end

%% Summarise
results.N               = N;
results.wallTime        = wallTime;
results.UAVmass         = UAVmass_samples;
results.landTime        = landTime_samples;
results.WP_offsets      = WP_offsets;
results.max_thrust      = max_thrust;
results.fault_triggered = fault_triggered;
results.crashed         = crashed;
results.n_crashed       = sum(crashed);
results.n_faults        = sum(fault_triggered & ~crashed);
results.thrust_mean     = mean(max_thrust(~crashed));
results.thrust_std      = std(max_thrust(~crashed));
results.thrust_p99      = prctile(max_thrust(~crashed), 99);

outDir = 'Verification/reports';
if ~exist(outDir, 'dir'); mkdir(outDir); end
save(fullfile(outDir, 'montecarlo_results.mat'), 'results');
fprintf('Saved: %s/montecarlo_results.mat\n', outDir);
fprintf('  Crashed : %d / %d\n', results.n_crashed, N);
fprintf('  Faults  : %d / %d\n', results.n_faults,  N);
fprintf('  Thrust  : mean=%.4f  std=%.4f  P99=%.4f\n', ...
        results.thrust_mean, results.thrust_std, results.thrust_p99);
