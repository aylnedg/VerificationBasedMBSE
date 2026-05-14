%% VerificationBasedMBSE — Project Startup
% Runs automatically when the project is opened.
% Initializes the Simulink Agentic Toolkit MCP connection.

disp('=== VerificationBasedMBSE: Project Startup ===')

% Initialize SATK (required for Claude Code MCP connectivity)
satkPath = 'C:\Users\aylin.edgu\simulink-agentic-toolkit';
if exist(satkPath, 'dir')
    addpath(satkPath);
    satk_initialize;
else
    warning('SATK path not found: %s', satkPath);
end

% Confirm project root is on path
projRoot = fileparts(mfilename('fullpath'));
addpath(projRoot);

disp('=== Startup complete. MCP ready. ===')
