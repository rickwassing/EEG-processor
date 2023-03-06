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
        jsonFile(1).folder = strrep(jsonFile(1).folder, filesep, '/');
        % -----
        % Generate filenames for the sidecar files
        KeysValues = filename2struct(rootName);
        Keys = fieldnames(KeysValues); Keys(end) = [];
        Values = struct2cell(KeysValues); Values(end) = [];
        BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
        ChannelFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'channels.tsv'}], '')];
        ElectrodesFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'electrodes.tsv'}], '')];
        EventsFilename = [newFiles(k).folder, '/', strjoin([BaseFilename; {'events.tsv'}], '')];
        % ---------------------------------------------------------
        % Add it to the structure
        id = ['X', datestr(now, 'HHMMSSFFF'), num2str(randomSeeds(k))];
        ids = [ids; {id}]; %#ok<AGROW>
        Files.Id{end+1} = id;
        Files.Path{end} = strrep([newFiles(k).folder, '/', newFiles(k).name], '\', '/');
        Files.SubId{end} = SubId;
        Files.Type{end} = type;
        Files.KeyVals{end} = KeysValues;
        % Load JSON
        if isempty(jsonFile)
            Files.JSON{end} = struct();
        else
            Files.JSON{end} = json2struct([jsonFile(1).folder, '/', jsonFile(1).name]);
        end
        % Load channels
        if exist(ChannelFilename, 'file') == 0
            Files.channels{end} = table([]);
        else
            Files.channels{end} = readSidecarTSV(ChannelFilename, 'channels');
        end
        % Load electrode positions
        if exist(ElectrodesFilename, 'file') == 0
            Files.chanlocs{end} = table([]);
        else
            Files.chanlocs{end} = readSidecarTSV(ElectrodesFilename, 'electrodes');
        end
        % Load events
        if exist(EventsFilename, 'file') == 0
            Files.events{end} = table();
        else
            Files.events{end} = readSidecarTSV(EventsFilename, 'events');
        end
        Files.Status{end} = 'idle';
    catch ME
        printME(ME);
        Files.Status{end} = 'error';
        Files.ErrorMessage{end} = printME(ME);
    end
end
end
