function [filename, unit, outputToken] = find_palm_output(outputDir, prefix, outputTokens, modality, design, contrast, varargin)
% Find one PALM output using its semantic filename components.
%
% PALM output units are determined by PALM and can differ between ordinary
% data statistics (for example, dat or dpv) and spatial statistics (for
% example, tfce or clustere). This function therefore discovers the unit
% from the file PALM actually wrote instead of predicting it from settings.

if ischar(outputTokens)
    outputTokens = {outputTokens};
elseif isstring(outputTokens)
    outputTokens = cellstr(outputTokens);
end

if nargin > 6 && ~isempty(varargin{1})
    expectedUnit = char(varargin{1});
else
    expectedUnit = '';
end

if ~isfolder(outputDir)
    error('EEGProcessor:PALMOutputDirectoryNotFound', ...
        'PALM output directory does not exist: %s', outputDir);
end
if ~iscell(outputTokens) || isempty(outputTokens) || ...
        ~all(cellfun(@ischar, outputTokens))
    error('EEGProcessor:InvalidPALMOutputToken', ...
        'outputTokens must be a character vector, string, or cell array of character vectors.');
end

files = dir(fullfile(outputDir, [prefix, '_*.csv']));
matches = struct('name', {}, 'folder', {}, 'unit', {}, 'outputToken', {});
escapedPrefix = regexptranslate('escape', prefix);

for tokenIdx = 1:numel(outputTokens)
    token = outputTokens{tokenIdx};
    expression = sprintf('^%s_(?<unit>[^_]+)_%s_m%d_d%d_c%d\.csv$', ...
        escapedPrefix, regexptranslate('escape', token), modality, design, contrast);
    for fileIdx = 1:numel(files)
        parsed = regexp(files(fileIdx).name, expression, 'names', 'once');
        if ~isempty(parsed)
            match.name = files(fileIdx).name;
            match.folder = files(fileIdx).folder;
            match.unit = parsed.unit;
            match.outputToken = token;
            matches(end+1) = match; %#ok<AGROW>
        end
    end
end

description = sprintf('%s_{unit}_{%s}_m%d_d%d_c%d.csv', ...
    prefix, strjoin(outputTokens, '|'), modality, design, contrast);
if isempty(matches)
    error('EEGProcessor:PALMOutputNotFound', ...
        'No PALM output matched "%s" in directory: %s', description, outputDir);
end

allMatches = matches;
if strcmp(expectedUnit, 'data')
    spatialUnits = {'tfce', 'clustere', 'clusterm'};
    matches = matches(~ismember({matches.unit}, spatialUnits));
elseif ~isempty(expectedUnit)
    matches = matches(strcmp({matches.unit}, expectedUnit));
end

if isempty(matches)
    error('EEGProcessor:UnexpectedPALMOutputUnit', ...
        'PALM outputs matching "%s" have units {%s}; expected "%s".', ...
        description, strjoin(unique({allMatches.unit}), ', '), expectedUnit);
elseif numel(matches) > 1
    error('EEGProcessor:AmbiguousPALMOutput', ...
        'Multiple PALM outputs matched "%s" in directory %s: %s', ...
        description, outputDir, strjoin({matches.name}, ', '));
end

unit = matches.unit;
outputToken = matches.outputToken;
filename = fullfile(matches.folder, matches.name);
end