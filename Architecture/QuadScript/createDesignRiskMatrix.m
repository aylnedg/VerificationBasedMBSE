function createDesignRiskMatrix(modelName)
% createDesignRiskMatrix Generates a risk matrix for security vulnerabilities in a System Composer model.
%
%   createDesignRiskMatrix('YourModelName')
%
%   This function loads a System Composer model, extracts all elements
%   (components, connectors, ports) with a specific security stereotype,
%   and visualizes their risk in a colored matrix.

%% --- Model and Stereotype Setup ---
ZCModel = modelName + ".slx"; % Model file name
ZCStereotype = 'SecurityProfile.SecurityVulnerability'; % Security stereotype

% Load the model architecture
zcModel = systemcomposer.loadModel(ZCModel);
ZCElements = zcModel.Architecture;

%% --- Collect Security Elements ---
securityElements = {}; % Use a cell array!
numSecurityElements = 0;

% Components
components = ZCElements.Components;
for i = 1:length(components)
    if any(strcmp(components(i).getStereotypes, ZCStereotype))
        numSecurityElements = numSecurityElements + 1;
        securityElements{numSecurityElements} = components(i); %#ok<*AGROW>
    end
end

% Connectors
connectors = ZCElements.Connectors;
for i = 1:length(connectors)
    if any(strcmp(connectors(i).getStereotypes, ZCStereotype))
        numSecurityElements = numSecurityElements + 1;
        securityElements{numSecurityElements} = connectors(i); %#ok<*AGROW>
    end
end

% Ports
ports = ZCElements.Ports;
for i = 1:length(ports)
    if any(strcmp(ports(i).getStereotypes, ZCStereotype))
        numSecurityElements = numSecurityElements + 1;
        securityElements{numSecurityElements} = ports(i); 
    end
end
% TODO: Add interface handling if required

%% --- Define Risk Matrix ---
% Risk levels: 1 (Low), 2 (Medium), 3 (Severe)
C = [2 3 3 3 3;
     1 2 3 3 3;
     1 1 2 3 3;
     1 1 1 2 3;
     1 1 1 1 2]; % Risk matrix

% Initialize value cells for matrix
Vcells = cell(25, 1);

% Property names for extraction
props = {...
    [ZCStereotype, '.Name'], ...
    [ZCStereotype, '.probabilityOfOccurence'], ...
    [ZCStereotype, '.extentOfDamage'], ...
    [ZCStereotype, '.costOfImplementation'] ...
};

%% --- Map Security Elements to Matrix Cells ---
for i = 1:numSecurityElements
    currElement = securityElements{i}; % Cell array access

    % Extract property values
    currElementValues = cellfun(@(x) getPropertyValue(currElement, x), props, 'UniformOutput', false);

    % Map string ratings to numeric values (1-5)
    damageRating = mapRating(currElementValues{3});
    probRating = mapRating(currElementValues{2});

    % Calculate cell index
    cellNum = damageRating + (probRating - 1) * 5;

    % Remove single quotes from the name for display
    cleanName = strrep(currElementValues{1}, '''', '');

    % Store element name in the appropriate cell
    if isempty(Vcells{cellNum})
        Vcells{cellNum} = cleanName;
    else
        Vcells{cellNum} = [Vcells{cellNum}, ', ', cleanName];
    end
end

% Replace empty cells with empty strings for display
for i = 1:numel(Vcells)
    if isempty(Vcells{i})
        Vcells{i} = '';
    end
end

%% --- Plot Risk Matrix ---
figure;
ax = axes;
hold on

% Draw colored grid
[X, Y] = meshgrid(1:size(C,1), 1:size(C,2));
imagesc(X(:), Y(:), flipud(C));

% Define colors: green (acceptable), yellow (warning), red (unacceptable)
cmap = [0 1 0; 1 1 0; 1 0 0];

% Add cell values (element names)
text(X(:), Y(:), Vcells, 'HorizontalAlignment', 'center', 'Interpreter', 'none')

% Define axis labels
RowLabels = {'Very Low', 'Low', 'Medium', 'High', 'Very High'};
ColLabels = {'Very Low', 'Low', 'Medium', 'High', 'Very High'};

set(gca, ...
    'xtick', unique(X), ...
    'ytick', unique(Y), ...
    'yticklabels', RowLabels, ...
    'xticklabels', ColLabels)

% Add colorbar and legend
cb = colorbar(ax, 'location', 'southoutside');
set(cb, ...
    'ticks', [1.3 2 2.7], ...
    'ticklabels', {'Acceptable Risk', 'Warning', 'Unacceptable Risk'}, ...
    'ticklength', 0)

box on
set(ax, 'layer', 'top');
ax.XAxis.Label.String = 'Probability of Occurrence';
ax.YAxis.Label.String = 'Extent of Damage';
ax.XGrid = 'on';
ax.YGrid = 'on';
colormap(cmap)
hold off

end

%% --- Helper Function: Map Rating String to Numeric Value ---
function rating = mapRating(ratingStr)
    ratingStr = strrep(ratingStr, '''', '');
    switch ratingStr
        case 'VeryLow'
            rating = 1;
        case 'Low'
            rating = 2;
        case 'Medium'
            rating = 3;
        case 'High'
            rating = 4;
        case 'VeryHigh'
            rating = 5;
        otherwise
            rating = 1; % Default/fallback
    end
end