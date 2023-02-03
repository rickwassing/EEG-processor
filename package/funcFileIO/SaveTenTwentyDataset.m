function [EEG, Next, Warnings] = SaveTenTwentyDataset(EEG, Settings, varargin)
% ---------------------------------------------------------
Next = 'none';
Warnings = [];
% ---------------------------------------------------------
% Check if we need to load the EEG
saveMemory = false;
if ischar(EEG)
    saveMemory = true;
    EEG = LoadDataset(EEG, 'all');
end
[EEG.filepath, EEG.setname] = fileparts(Settings.Path);
EEG.filename = [EEG.setname, '.edf'];
% ---------------------------------------------------------
% Check if 'KeepPhysChans' is set or set to default otherwise
if ~isfield(Settings, 'KeepPhysChans')
    Settings.KeepPhysChans = false;
end
% ---------------------------------------------------------
% Create Directory if it does not exist yet
if exist(EEG.filepath, 'dir') == 0
    CreateNewDirectory(EEG.filepath)
end
% ---------------------------------------------------------
% Make sure all event labels are lower-case
EEG = forceValidEventType(EEG);
% ---------------------------------------------------------
% Make sure the channel locations are correct
EEG = check_chanlocs(EEG, true);
% ---------------------------------------------------------
% Load the montage
MONT = ten_twenty_montage();
% ---------------------------------------------------------
% Vector to reorder the data at the end
newIdx = [];
% ---------------------------------------------------------
% Extract the fieldnames of the montage
fnames = fieldnames(MONT);
% ---------------------------------------------------------
% If there are any rejected channels, check if we need to interpolate
if isfield(EEG.etc, 'rej_channels')
    % Extract which channels we want to select
    chans = {};
    for i = 1:length(fnames)
        chans = [chans, {MONT.(fnames{i}).chan}, MONT.(fnames{i}).ref]; %#ok<AGROW>
    end
    chans = unique(chans);
    % If any of the selected channels is a bad one, then interpolate all
    % bad channels
    if any(ismember(EEG.etc.rej_channels, chans))
        disp('>> BIDS: Interpolating rejected channels')
        EEG = eeg_interp(EEG, find(...
            ismember({EEG.chanlocs.labels}, EEG.etc.rej_channels) ...
            ));
    end
end        
% ---------------------------------------------------------
% Extract the current EEG data which is referenced to Cz
eegdata = EEG.data(strcmpi({EEG.chanlocs.type}, 'EEG'), :, :);
% Also extract the phys data in case we need to add it back
pibdata = EEG.data(~strcmpi({EEG.chanlocs.type}, 'EEG'), :, :);
pibchanlocs = EEG.chanlocs(~strcmpi({EEG.chanlocs.type}, 'EEG'));
% Take out the EOG channels, they are part of the montage
pibdata(...
    strcmpi({pibchanlocs.type}, 'EOG') | ...
    strcmpi({pibchanlocs.type}, 'VEOG') | ...
    strcmpi({pibchanlocs.type}, 'HEOG'), :, :) = [];
pibchanlocs(...
    strcmpi({pibchanlocs.type}, 'EOG') | ...
    strcmpi({pibchanlocs.type}, 'VEOG') | ...
    strcmpi({pibchanlocs.type}, 'HEOG')) = [];
% And reset the data
EEG.data = zeros(length(fnames), EEG.pnts, 'single');
EEG.chanlocs(:) = [];
EEG.ref = 'mixed';
% ---------------------------------------------------------
% For each field in the montage ...
for fi = 1:length(fnames)
    % ... find the index of the channel and its reference channels
    idxChan = find(strcmpi({EEG.urchanlocs.labels}, MONT.(fnames{fi}).chan));
    idxRef  = find(ismember({EEG.urchanlocs.labels}, MONT.(fnames{fi}).ref));
    % Rereference the data
    EEG.data(fi, :) = eegdata(idxChan, :) - mean(eegdata(idxRef, :), 1); %#ok<FNDSB>
    % Update the channel locations structure
    EEG.chanlocs(fi) = EEG.urchanlocs(idxChan);
    EEG.chanlocs(fi).labels = fnames{fi};
    EEG.chanlocs(fi).ref = MONT.(fnames{fi}).ref;
    if regexpIdx(fnames{fi}, 'EOG')
        EEG.chanlocs(fi).type = 'EOG';
    else
        EEG.chanlocs(fi).type = 'EEG';
    end
    newIdx = [newIdx, idxChan]; %#ok<AGROW>
end
% ---------------------------------------------------------
% Update number of channels
EEG.nbchan = size(EEG.data, 1);
% ---------------------------------------------------------
% If this is a PSG recording, crop to a multiple of 30 second epochs
if isfield(EEG.etc, 'stages')
    crop = floor(EEG.pnts/(30*EEG.srate))*30*EEG.srate;
    EEG = pop_select(EEG, 'point', [1 crop]);
end
% ---------------------------------------------------------
% Filter the data
EEG = pop_firws(EEG, ...
    'fcutoff', [0.25 45], ...
    'ftype', 'bandpass', ...
    'wtype', 'hamming', ...
    'forder', 5500, ...
    'minphase', 0);
% ---------------------------------------------------------
% Crop any data above and below 5000 uV as the EDF uses low-resolution 16-bit encoding.
disp('>> BIDS: Cropping the EEG amplitude to +/- 5000 uV')
pntsCropped = sum((abs(EEG.data(:)) > 5000));
totPnts = EEG.pnts*EEG.nbchan;
warnmsg = sprintf('%i/%i samples (%.2f%%) were cropped to 5000 uV\n', ...
    pntsCropped, ...
    totPnts, ...
    100*pntsCropped/totPnts);
Warnings = [Warnings, {warnmsg; '-----'}];
% Crop the data
for ch = 1:EEG.nbchan
    EEG.data(ch, EEG.data(ch, :) >  5000) =  5000;
    EEG.data(ch, EEG.data(ch, :) <  -5000) =  -5000;
end
% ---------------------------------------------------------
% Add back the physiology data if that is requested
if Settings.KeepPhysChans
    EEG.data = [EEG.data; pibdata];
    EEG.chanlocs = [EEG.chanlocs, pibchanlocs];
    EEG.nbchan = size(EEG.data, 1);
end
% ---------------------------------------------------------
% Write to file
disp('>> BIDS: Saving the dataset to EDF')
T = now;
% Make sure no events have an onset less than 1, or we'll get an error
for i = 1:length(EEG.event)
    if EEG.event(i).latency < 1
        EEG.event(i).latency = 1;
    end
end
pop_writeeeg(EEG, [Settings.Path, '.edf'], 'TYPE', 'EDF');
% ---------------------------------------------------------
% Update JSON
EEG.etc.JSON.Sources = fullpath2bidsuri(Settings.ProtocolPath, Settings.Path);
EEG.etc.JSON.EEGReference = 'mixed';
EEG.etc.JSON.EEGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'EEG'));
EEG.etc.JSON.ECGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'ECG'));
EEG.etc.JSON.EMGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'EMG'));
EEG.etc.JSON.EOGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'EOG') | strcmpi({EEG.chanlocs.type}, 'VEOG') | strcmpi({EEG.chanlocs.type}, 'HEOG'));
EEG.etc.JSON.MiscChannelCount = EEG.nbchan - ...
    EEG.etc.JSON.EEGChannelCount - ...
    EEG.etc.JSON.ECGChannelCount - ...
    EEG.etc.JSON.EMGChannelCount - ...
    EEG.etc.JSON.EOGChannelCount;
EEG.etc.JSON.SoftwareFilters = struct();
EEG.etc.JSON.SoftwareFilters.BandPass.FilterType = 'Windowed sinc FIR filter';
EEG.etc.JSON.SoftwareFilters.BandPass.Window = 'Hamming';
EEG.etc.JSON.SoftwareFilters.BandPass.PassBand = [0.25, 45];
EEG.etc.JSON.SoftwareFilters.BandPass.TransitionBandwidth = 0.5;
EEG.etc.JSON.SoftwareFilters.BandPass.Order = 5500;
% ---------------------------------------------------------
% Save Sidecar files
% -----
% Get keys and values
KeysValues = filename2struct(EEG.setname);
Keys = fieldnames(KeysValues); Keys(end) = [];
Values = struct2cell(KeysValues); Values(end) = [];
% -----
% Generate filenames for all the sidecar files
BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
JSONFilename = [EEG.filepath, '/', EEG.setname, '.json'];
ChannelFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'channels.tsv'}], '')];
ElectrodesFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'electrodes.tsv'}], '')];
CoordFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'coordsystem.json'}], '')];
EventsFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'events.tsv'}], '')];
% -----
% Save Sidecar Files
struct2json(EEG.etc.JSON, JSONFilename);
writeChannelsTSV(EEG, ChannelFilename);
writeElectrodesTSV(EEG, ElectrodesFilename);
writeCoordinateSystemJSON(EEG, CoordFilename);
writeEventsTSV(EEG, EventsFilename);
% ---------------------------------------------------------
% Print how long it took
fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
% ---------------------------------------------------------
% Remove any large data to save memory if needed
if saveMemory
    EEG.data = []; % To save memory
    EEG.times = [];
    EEG.specdata = [];
    EEG.specchans = [];
    EEG.specfreqs = [];
    EEG.spectimes = [];
    EEG.specnormmethod = 'none';
    EEG.specnormvals = struct();
    EEG.specnormfnc = [];
    EEG.icaact = [];
    EEG.icawinv = [];
    EEG.icasphere = [];
    EEG.icaweights = [];
    EEG.icachansind = [];
    EEG.specicaact = [];
end
EEG.filepath = strrep(EEG.filepath, filesep, '/');
% What step to do next?
Next = 'AddFile';

end
