function EEG = UpdateDatasetWithSidecars(EEG, FullFilePath)
% ---------------------------------------------------------
% Load Sidecar files
fprintf('>> BIDS: Updating EEG struct with sidecar files from ''%s''\n', FullFilePath)
% -----
[EEG.filepath, EEG.setname, Extension] = fileparts(FullFilePath);
EEG.filename = [EEG.setname, Extension];
% -----
% Get keys and values
[~, Filename] = fileparts(EEG.setname);
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
% Set header info
EEG.subject = KeysValues.sub;
EEG.session = KeysValues.ses;
% -----
Channels = readSidecarTSV(ChannelFilename, 'channels');
if any(~strcmpi(Channels.status, 'good'))
    EEG.etc.rej_channels = asrow(Channels.name(~strcmpi(Channels.status, 'good')));
end
% -----
Coordinates = jsondecode(fileread(CoordFilename));
EEG.chaninfo = struct();
Labels = fieldnames(Coordinates.AnatomicalLandmarkCoordinates);
for i = 1:length(Labels)
    EEG.chaninfo.ndchanlocs(i).labels = Labels{i};
    EEG.chaninfo.ndchanlocs(i).X = Coordinates.AnatomicalLandmarkCoordinates.(Labels{i})(1);
    EEG.chaninfo.ndchanlocs(i).Y = Coordinates.AnatomicalLandmarkCoordinates.(Labels{i})(2);
    EEG.chaninfo.ndchanlocs(i).Z = Coordinates.AnatomicalLandmarkCoordinates.(Labels{i})(3);
    EEG.chaninfo.ndchanlocs(i).type = 'FID';
end
EEG.chaninfo.filename = CoordFilename;
EEG.chaninfo.plotrad = [];
EEG.chaninfo.shrink = [];
switch Coordinates.EEGCoordinateSystem
    case {'ALS', 'ARS'}
        EEG.chaninfo.nosedir = '+X';
    case {'PLS', 'PRS'}
        EEG.chaninfo.nosedir = '-X';
    case {'LAS', 'RAS'}
        EEG.chaninfo.nosedir = '+Y';
    case {'LPS', 'RPS'}
        EEG.chaninfo.nosedir = '-Y';
    case {'LSA', 'RSA'}
        EEG.chaninfo.nosedir = '+Z';
    case {'LSP', 'RSP'}
        EEG.chaninfo.nosedir = '-Z';
end
% -----
EEG.event = struct();
Events = readSidecarTSV(EventsFilename, 'events');
for i = 1:size(Events, 1)
    EEG.event(i).latency = Events.onset(i)*EEG.srate;
    EEG.event(i).duration = Events.duration(i)*EEG.srate;
    EEG.event(i).type = strrep(Events.trial_type{i}, 'artifact_', '');
    EEG.event(i).id = i;
    EEG.event(i).is_reject = ifelse(regexpIdx(Events.trial_type{i}, 'artifact'), true, false);
    if EEG.trials > 1
        EEG.event(i).epoch = ceil(EEG.event(i).latency/EEG.pnts);
    end
end
% -----
EEG.etc.JSON = jsondecode(fileread(JSONFilename));

end