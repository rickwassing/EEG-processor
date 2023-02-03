function EEG = SaveDataset(EEG, Part)

if nargin < 2
    Part = 'all';
end

T = now;

% ---------------------------------------------------------
% Create Directory if it does not exist yet
if exist(EEG.filepath, 'dir') == 0
    CreateNewDirectory(EEG.filepath)
end
if strcmpi(Part, 'all')
    % ---------------------------------------------------------
    % Make sure the EEG channels appear first, then the PNS channels
    EEG = forceChannelOrder(EEG);
end
% ---------------------------------------------------------
% Make sure all event labels are lower-case
EEG = forceValidEventType(EEG);
% ---------------------------------------------------------
% Make sure the channel locations are correct
EEG = check_chanlocs(EEG, true);
% ---------------------------------------------------------
% Make sure the EEG.times is in seconds
if isfield(EEG, 'times')
    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
end
% ---------------------------------------------------------
% Save dataset
if strcmpi(Part, 'all')
    fprintf('>> BIDS: Saving dataset to ''%s''\n', EEG.setname)
    EEG = eeg_checkset(EEG, 'eventconsistency');
    EEG = pop_saveset(EEG, [EEG.filepath, '/', EEG.filename]);
    EEG.filepath = strrep(EEG.filepath, filesep, '/');
end
% ---------------------------------------------------------
% Save Header 
if strcmpi(Part, 'header')
    fprintf('>> BIDS: Saving header info to ''%s''\n', EEG.setname)
    EEG = eeg_checkset(EEG, 'eventconsistency');
    % Make sure the data is no longer part of the 'EEG' variable
    tmpeeg = EEG; % Keep the original data to place back later (does not require extra memory, see 'https://au.mathworks.com/help/matlab/matlab_prog/memory-allocation.html')
    EEG = rmfield(EEG, 'data'); % Remove the 'data' field
    % Add the datafile name to the data field
    if isfield(EEG, 'datfile')
        EEG.data = EEG.datfile;
    else
        EEG.data = [EEG.setname, '.fdt'];
    end
    % Save the header
    save([EEG.filepath, '/', EEG.filename], '-v7.3', '-mat', 'EEG');
    % Place the data back and remove 'tmpeeg';
    EEG = tmpeeg;
    clear tmpeeg;
end
% ---------------------------------------------------------
% Save structure with generic matrix as data 
if strcmpi(Part, 'matrix')
    fprintf('>> BIDS: Saving matrix dataset to ''%s''\n', EEG.filename)
    save([EEG.filepath, '/', EEG.filename], '-v7.3', '-mat', 'EEG');
end
% ---------------------------------------------------------
% Save Sidecar files
fprintf('>> BIDS: Saving sidecar files\n')
% -----
% Get keys and values
[~, Filename] = fileparts(EEG.filename);
KeysValues = filename2struct(Filename);
Keys = fieldnames(KeysValues); Keys(end) = [];
Values = struct2cell(KeysValues); Values(end) = [];
% -----
% Generate filenames for all the sidecar files
BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
JSONFilename = [EEG.filepath, '/', Filename, '.json'];
ChannelFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'channels.tsv'}], '')];
ElectrodesFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'electrodes.tsv'}], '')];
CoordFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'coordsystem.json'}], '')];
EventsFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'events.tsv'}], '')];
% -----
% Save Sidecar Files
if isfield(EEG.etc, 'JSON')
    struct2json(EEG.etc.JSON, JSONFilename);
end
if isfield(EEG, 'chanlocs')
    writeChannelsTSV(EEG, ChannelFilename);
    writeElectrodesTSV(EEG, ElectrodesFilename);
end
if isfield(EEG, 'chaninfo')
    writeCoordinateSystemJSON(EEG, CoordFilename);
end
if isfield(EEG, 'event')
    writeEventsTSV(EEG, EventsFilename);
end
% ---------------------------------------------------------
% Print how long it took
fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))

end
