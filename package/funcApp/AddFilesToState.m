function [Files, ids] = AddFilesToState(Files, SubId, newFiles, type, ids)
% ---------------------------------------------------------
% For each file, add it to the structure
randomSeeds = randperm(length(newFiles), length(newFiles));
for k = 1:length(newFiles)
    try
        % ---------------------------------------------------------
        % Find the associated JSON file
        [~, rootName] = fileparts(newFiles(k).name);
        jsonFile = dir([newFiles(k).folder, '/', rootName, '.json']);
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
        Files.ids = [Files.ids; {id}];
        Files.Entities.(id).Id = id;
        Files.Entities.(id).Path = strrep([newFiles(k).folder, '/', newFiles(k).name], '\', '/');
        Files.Entities.(id).SubId = SubId;
        Files.Entities.(id).Type = type;
        Files.Entities.(id).KeyVals = KeysValues;
        % Load JSON
        if isempty(jsonFile)
            Files.Entities.(id).JSON = struct();
        else
            Files.Entities.(id).JSON = json2struct([jsonFile(1).folder, '/', jsonFile(1).name]);
        end
        % Load channels
        if exist(ChannelFilename, 'file') == 0
            Files.Entities.(id).channels = table();
        else
            Files.Entities.(id).channels = readSidecarTSV(ChannelFilename, 'channels');
        end
        % Load electrode positions
        if exist(ElectrodesFilename, 'file') == 0
            Files.Entities.(id).chanlocs = table();
        else
            Files.Entities.(id).chanlocs = readSidecarTSV(ElectrodesFilename, 'electrodes');
        end
        % Load events
        if exist(EventsFilename, 'file') == 0
            Files.Entities.(id).events = table();
        else
            Files.Entities.(id).events = readSidecarTSV(EventsFilename, 'events');
        end
        Files.Entities.(id).Status = 'idle';
    catch ME
        printME(ME);
        Files.Entities.(id).Status = 'error';
        Files.Entities.(id).ErrorMessage = ME;
    end
end
end
