function [ArgOut, Next, Warnings] = ProcSelectData(app, File, Settings)
% ---------------------------------------------------------
% Initialize
ArgOut = [];
Next = 'none';
Warnings = [];
% ---------------------------------------------------------
% Get data path
[~, filename] = fileparts(File.Path);
% ---------------------------------------------------------
% Check if dataset exists
if exist(File.Path) == 0 %#ok<EXIST> 
    Warnings = [Warnings; {sprintf('Could not load dataset ''%s'', file not found.', filename)}];
    Warnings = [Warnings; {'-----'}];
    return
end
% ---------------------------------------------------------
% Load data
disp('>> BIDS: Loading dataset')
Settings.EEG = LoadDataset(File.Path, 'all');
% ---------------------------------------------------------
% Force a continuous dataset
if Settings.EEG.trials > 1
    Settings.EEG = eeg_epoch2continuous(Settings.EEG);
    Settings.EEG.xmin = 0;
    Settings.EEG.xmax = Settings.EEG.pnts/Settings.EEG.srate - 1/Settings.EEG.srate;
    Settings.EEG.times = Settings.EEG.xmin:1/Settings.EEG.srate:Settings.EEG.xmax;
    Settings.EEG.etc.RecordingDuration = Settings.EEG.pnts/Settings.EEG.srate;
    Settings.EEG.etc.RecordingType = 'discontinuous';
    Settings.EEG.etc.TrialCount = 1;
end
% ---------------------------------------------------------
% Make sure each event has an 'ID' and an 'is_reject' field
if ~isfield(Settings.EEG.event, 'id')
    for i = 1:length(Settings.EEG.event)
        Settings.EEG.event(i).id = i;
    end
end
if ~isfield(Settings.EEG.event, 'is_reject')
    for i = 1:length(Settings.EEG.event)
        Settings.EEG.event(i).is_reject = false;
    end
end
% ---------------------------------------------------------
% Remove rejected components
if Settings.Reject.Components
    [Settings.EEG, Warnings] = Proc_RejectComponents(Settings.EEG, Warnings);
end
% ---------------------------------------------------------
% Check if reject channels exist
if ~isfield(Settings.EEG.etc, 'rej_channels')
    % If not any rejected channels are defined set all channels to false
    RejChansExist = false;
else
    RejChansExist = true;
end
% Get the rejected channel indices
if RejChansExist
    RejChans = Settings.EEG.etc.rej_channels;
else
    RejChans = [];
end
% ---------------------------------------------------------
% Apply average reference
if Settings.Processing.DoAverageRef
    Settings.EEG = Proc_AverageRef(Settings.EEG, Settings.Processing, RejChans);
end
% ---------------------------------------------------------
% Delete or interpolate rejected channels
if Settings.Reject.Channels
    [Settings.EEG, Warnings] = Proc_RejectChannels(Settings.EEG, Settings.Reject, RejChans, Warnings);
end
% ---------------------------------------------------------
% Select time
% However, if the user wants to select EEG based on an event onset and
% duration, then this can be done later
if ~Settings.TimeSel.AllFile && ~(Settings.EventSel.Do && ~Settings.EventSel.UseEpochTime)
    fprintf('>> BIDS: Selecting subset of data between %.3f and %.3f seconds\n', Settings.TimeSel.Interval(1), Settings.TimeSel.Interval(2))
    Settings.EEG = pop_select(Settings.EEG, 'time', Settings.TimeSel.Interval);
    Settings.EEG.etc.JSON.RecordingDuration = Settings.EEG.pnts/Settings.EEG.srate;
end
% -------------------------------------------------------------------------
% Check if filtering is set, if so, do filter, otherwise update JSON
Settings.EEG = Proc_TemporalFilter(Settings.EEG, Settings.Processing);
% ---------------------------------------------------------
% Check if resampling is set, if so, do resample, otherwise update JSON
Settings.EEG = Proc_Resample(Settings.EEG, Settings.Processing);
% ---------------------------------------------------------
% Remove the viewsettings
if isfield(Settings.EEG.etc, 'viewsettings')
    Settings.EEG.etc = rmfield(Settings.EEG.etc, 'viewsettings');
end
% ---------------------------------------------------------
% Remove the FASTER Stats
if isfield(Settings.EEG.etc, 'faster')
    Settings.EEG.etc = rmfield(Settings.EEG.etc, 'faster');
end
% ---------------------------------------------------------
% Remove the Spectrogram
Settings.EEG.specdata = [];
Settings.EEG.specchans = [];
Settings.EEG.specfreqs = [];
Settings.EEG.spectimes = [];
Settings.EEG.specnormmethod = 'none';
Settings.EEG.specnormvals = struct();
Settings.EEG.specnormfnc = [];
% ---------------------------------------------------------
% Remove the ICA
Settings.EEG.icaact = [];
Settings.EEG.icawinv = [];
Settings.EEG.icasphere = [];
Settings.EEG.icaweights = [];
Settings.EEG.icachansind = [];
Settings.EEG.specicaact = [];
% ---------------------------------------------------------
% Split the dataset in epochs
if Settings.Split.Do
    [Settings.EEG, Warnings] = Proc_EpochSplit(Settings.EEG, Settings.Split, Settings.Reject, Warnings);
end
% ---------------------------------------------------------
% Event Selection
if Settings.EventSel.Do
    [Settings.EEG, Warnings] = Proc_EpochEventSel(Settings.EEG, Settings.EventSel, Settings.Reject, Settings.TimeSel, Warnings);
end
% ---------------------------------------------------------
% If the file is not split or epoched by events, then we still have
% to remove bad segments if the user requested this.
if ~Settings.Split.Do && ~Settings.EventSel.Do && Settings.Reject.Epochs && ~isempty(Settings.EEG.event)
    RejIdx = eegevent2idx(Settings.EEG.event([Settings.EEG.event.is_reject] == 1), 1:Settings.EEG.pnts);
    if any(RejIdx)
        fprintf('>> BIDS: Removing %.3f s of rejected epochs\n', sum(RejIdx)/Settings.EEG.srate)
        [PointOnset, PointDuration] = idx2bouts(~RejIdx);
        Settings.EEG = pop_select(Settings.EEG, 'point', [PointOnset, PointOnset+PointDuration]);
        % make sure there is an 'id' and 'is_reject' value for each event
        for j = 1:length(Settings.EEG.event)
            Settings.EEG.event(j).id = j;
            if isempty(Settings.EEG.event(j).is_reject)
                Settings.EEG.event(j).is_reject = 0;
            end
        end
        % Also remove the reject events
        Settings.EEG.event([Settings.EEG.event.is_reject] == 1) = [];
        % Update the JSON Struct
        Settings.EEG.etc.JSON.RecordingDuration = Settings.EEG.pnts/Settings.EEG.srate;
        Settings.EEG.etc.JSON.RecordingType = 'discontinuous';
        Settings.EEG.etc.JSON.TrialCount = Settings.EEG.trials;
    end
end
% ---------------------------------------------------------
% ICA
for i = 1:length(Settings.EEG)
    % Check if there is any data at all
    if Settings.EEG(i).pnts == 1
        continue
    end
    % Check if ICA is set, if so, do ICA, otherwise update JSON
    [Settings.EEG(i), Warnings] = Analysis_ICA(Settings.EEG(i), Settings.Processing, RejChans, Warnings);
end
% ---------------------------------------------------------
% Remove DC offset
for i = 1:length(Settings.EEG)
    % Check if there is any data at all
    if Settings.EEG(i).pnts == 1
        continue
    end
    % Check if DC offset is set, if so, do remove DC, otherwise update JSON
    Settings.EEG(i) = Analysis_RemoveDC(Settings.EEG(i), Settings.Processing);
end
% ---------------------------------------------------------
% Multitaper wavelet
for i = 1:length(Settings.EEG)
    % Check if there is any data at all
    if Settings.EEG(i).pnts == 1
        continue
    end
    % Check if spectrogram is set, if so, do spectrogram, otherwise update JSON
    [Settings.EEG(i), Warnings] = Analysis_Spectrogram(Settings.EEG(i), Settings.Processing, RejChans, Warnings);
end
% ---------------------------------------------------------
% Set the filepath
KeysValues = filename2struct(Settings.RecordingName.Setname);
for i = 1:length(Settings.EEG)
    Settings.EEG(i).subject = KeysValues.sub;
    % ID #0006
    % For legacy support, check if the 'EEG-select' directory exists, otherwise use 'EEG-preproc'
    if exist([app.State.Protocol.Path, '/derivatives/EEG-select'], 'dir') == 0
        Settings.EEG(i).filepath = [app.State.Protocol.Path, '/derivatives/EEG-preproc/sub-', KeysValues.sub, '/ses-', KeysValues.ses];
    else
        Settings.EEG(i).filepath = [app.State.Protocol.Path, '/derivatives/EEG-select/sub-', KeysValues.sub, '/ses-', KeysValues.ses];
    end
end
% ---------------------------------------------------------
% Set set and filenames and save the dataset
if Settings.EventSel.Do && Settings.EventSel.SeparateFiles
    for i = 1:length(Settings.EventSel.Labels)
        % Check if there is any data at all
        if Settings.EEG(i).pnts == 1
            fprintf('>> BIDS: Did not save dataset %i of %i, no data remaining.\n', i, length(Settings.EEG))
            continue
        end
        Settings.EEG(i).setname = [ ...
            'sub-', KeysValues.sub, '_', ...
            'ses-', KeysValues.ses, '_', ...
            'task-', KeysValues.task, '_', ...
            'run-', KeysValues.run, '_', ...
            'desc-', lower(Settings.EventSel.Labels{i}), '_', ...
            KeysValues.filetype];
        Settings.EEG(i).filename = [Settings.EEG(i).setname, '.set'];
        Settings.EEG(i).datfile = [Settings.EEG(i).setname, '.fdt'];
        fprintf('>> BIDS: Saving dataset %i of %i to ''%s''\n', i, length(Settings.EEG), Settings.EEG(i).filename)
        Settings.EEG(i) = SaveDataset(Settings.EEG(i), 'all');
    end
else
    for i = 1:length(Settings.EEG)
        % Check if there is any data at all
        if Settings.EEG(i).pnts == 1
            fprintf('>> BIDS: Did not save dataset %i of %i, no data remaining.\n', i, length(Settings.EEG))
            continue
        end
        Settings.EEG(i).setname = Settings.RecordingName.Setname;
        Settings.EEG(i).filename = [Settings.RecordingName.Setname, '.set'];
        Settings.EEG(i).datfile = [Settings.RecordingName.Setname, '.fdt'];
        fprintf('>> BIDS: Saving dataset %i of %i to ''%s''\n', i, length(Settings.EEG), Settings.EEG(i).filename)
        Settings.EEG(i) = SaveDataset(Settings.EEG(i), 'all');
    end
end
% -------------------------------------------------------------------------
% Generate the output variable
for i = 1:length(Settings.EEG)
    Settings.EEG(i).data = []; % To save memory
    Settings.EEG(i).specdata = [];
    Settings.EEG(i).times = [];
    Settings.EEG(i).icawinv = [];
    Settings.EEG(i).icawsphere = [];
    Settings.EEG(i).icawchansind = [];
    Settings.EEG(i).filepath = strrep(Settings.EEG(i).filepath, filesep, '/');
end
ArgOut = Settings.EEG;
% What step to do next?
Next = 'AddFile';
end