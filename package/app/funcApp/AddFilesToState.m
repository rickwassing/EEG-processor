function [Files, ids] = AddFilesToState(Files, SubId, newFiles, type, ids)
% ---------------------------------------------------------
% For each file, add it to the structure
randomSeeds = randperm(length(newFiles), length(newFiles));
for k = 1:length(newFiles)
    try
        % ---------------------------------------------------------
        % Replace backslashes
        newFiles(k).folder = strrep(newFiles(k).folder, filesep, '/');
        % -----
        % Find the associated JSON file
        [~, rootName] = fileparts(newFiles(k).name);
        jsonFile = dir([newFiles(k).folder, '/', rootName, '.json']);
        if ~isempty(jsonFile)
            jsonFile(1).folder = strrep(jsonFile(1).folder, filesep, '/');
        end
        % -----
        % Generate filenames for the sidecar files
        KeysValues = filename2struct(rootName);
        Keys = fieldnames(KeysValues); Keys(end) = [];
        Values = struct2cell(KeysValues); Values(end) = [];
        BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
        ChannelFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'channels.tsv'}], '')];
        ElectrodesFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'electrodes.tsv'}], '')];
        EventsFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'events.tsv'}], '')];
        HistoryFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'history.json'}], '')];
        % ---------------------------------------------------------
        % Add it to the structure
        id = ['X', datestr(now, 'HHMMSSFFF'), num2str(randomSeeds(k))];
        ids = [ids; {id}]; %#ok<AGROW>
        f = table();
        f.Id = {id};
        f.Path = {strrep([newFiles(k).folder, '/', newFiles(k).name], '\', '/')};
        f.SubId = {SubId};
        f.Type = {type};
        f.KeyVals = {KeysValues};
        % Load JSON
        if isempty(jsonFile)
            f.JSON = {struct()};
        else
            f.JSON = {json2struct([jsonFile(1).folder, '/', jsonFile(1).name])};
        end
        % Load channels
        if exist(ChannelFilename, 'file') == 0
            f.channels = {table([])};
        else
            f.channels = {readSidecarTSV(ChannelFilename, 'channels')};
        end
        % Load electrode positions
        if exist(ElectrodesFilename, 'file') == 0
            f.chanlocs = {table([])};
        else
            f.chanlocs = {readSidecarTSV(ElectrodesFilename, 'electrodes')};
        end
        % Load events
        if exist(EventsFilename, 'file') == 0
            f.events = {table()};
        else
            f.events = {readSidecarTSV(EventsFilename, 'events')};
        end
        % Load history
        if exist(HistoryFilename, 'file') == 0
            f.history = {struct([])};
        
        %% jsondecode converts a JSON string into a MATLAB structure
        else
            try
                f.history = {jsondecode(fileread(HistoryFilename))};
            catch ME %#ok<NASGU>
                f.history = {struct([])};
                % getReport(ME)
            end
        end
        f.Status = {'idle'};
        f.ErrorMessage = {''};
    catch ME
        disp(getReport(ME));  % Display full error
        f.Status = {'error'};
        f.ErrorMessage = {getReport(ME, 'basic')};
    end
    f.PrevState = {[]};
    Files = [Files; f]; %#ok<AGROW>
end
end