function runAnimation(scenario)
%RUNANIMATION Run UAV simulation with live 3-D animation.
%   scenario: 'nominal' | 'adversarial' | 'custom'
%
%   Usage: runAnimation('nominal')
%
%   The UAV Animation block inside Visualization renders live
%   in a MATLAB figure window during sim().  Results (final
%   WorldPosition, fault status, mission outcome) are printed
%   to the command window.

projRoot = 'C:/UAV/VerificationBasedMBSE';
addpath(fullfile(projRoot, 'Architecture/QuadScript'));
openProject(fullfile(projRoot, 'VerificationBasedMBSE.prj'));

switch scenario
    case 'nominal'
        setVariantConfig('Nominal_MAVLink');
        stopT    = '30';
        titleStr = 'Nominal MAVLink — Autonomous Waypoint Mission';

    case 'adversarial'
        setVariantConfig('Adversarial_MAVLink');
        stopT    = '20';
        titleStr = 'Adversarial — MAVLink Spoof Active at t=7s';

    case 'custom'
        setVariantConfig('Custom_NoThreat');
        stopT    = '30';
        titleStr = 'Custom Protocol — No Threat';

    otherwise
        error('Unknown scenario: %s', scenario);
end

fprintf('\n=== %s ===\n', titleStr);
fprintf('Starting simulation (StopTime=%ss)...\n', stopT);

open_system('QuadArchitecture');

t0  = tic;
out = sim('QuadArchitecture', 'StopTime', stopT);
dt  = toc(t0);

fprintf('Simulation completed in %.1f s\n', dt);

% Extract final UAVState WorldPosition from logsout{3} (<WorldPosition>)
try
    ls       = out.logsout;
    wpSig    = ls{3}.Values;          % [3 x 1 x T]
    wpData   = squeeze(wpSig.Data);   % [3 x T]
    finalPos = wpData(:, end);        % [x; y; z] at final step

    faultSig = ls{2}.Values;
    anyFault = any(double(faultSig.Data(:)) > 0.5);

    fprintf('Final WorldPosition: x=%.4f  y=%.4f  z=%.4f m\n', ...
            finalPos(1), finalPos(2), finalPos(3));
    fprintf('Any fault fired    : %s\n', mat2str(anyFault));

    % Mission outcome heuristic: reached near origin at altitude ≈ 0
    nearOrigin = norm(finalPos(1:2)) < 0.5 && abs(finalPos(3)) < 0.2;
    if isempty(out.ErrorMessage)
        if nearOrigin
            fprintf('Mission outcome    : COMPLETED (UAV at landing zone)\n');
        else
            fprintf('Mission outcome    : IN-PROGRESS (did not reach landing zone in StopTime)\n');
        end
    else
        fprintf('Mission outcome    : ABORTED (%s)\n', out.ErrorMessage);
    end
catch ME
    fprintf('Result extraction failed: %s\n', ME.message);
end

fprintf('Wall time: %.1f s\n\n', dt);
end
