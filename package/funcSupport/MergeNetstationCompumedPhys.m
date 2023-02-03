function EEG = MergeNetstationCompumedPhys(cfg)
% --------------------------------------------------
% Check inputs
if ~isfield(cfg, 'subject')
    Import.Subject = 'x';
else
    Import.Subject = cfg.subject;
end
if ~isfield(cfg, 'session')
    Import.Session = '1';
else
    Import.Session = cfg.session;
end
if ~isfield(cfg, 'task')
    Import.Task = 'x';
else
    Import.Task = cfg.task;
end
if ~isfield(cfg, 'run')
    Import.Run = 1;
else
    Import.Run = cfg.run;
end
if ~isfield(cfg, 'confirm')
    confirm = true;
else
    confirm = cfg.confirm;
end
% Check that source data are valid
if ~isfield(cfg, 'mff')
    error('MFF file not specified. This is required.');
end
if exist(cfg.mff) == 0 %#ok<EXIST> 
    error('MFF file does not exist.');
end
if ~isfield(cfg, 'edf')
    error('EDF file not specified. This is required.');
end
if exist(cfg.edf) == 0 %#ok<EXIST> 
    error('EDF file does not exist.');
end
if ~isfield(cfg, 'mff_marker')
    error('Marker label in the MFF file not specified. This is required.');
end
if ~isfield(cfg, 'edf_marker')
    error('Marker label in the EDF file not specified. This is required.');
end
% Check that the save-path is specified
if ~isfield(cfg, 'savepath')
    error('Save-path not specified. This is required.');
end
% Check that the channel locations are specified
if strcmpi(cfg.chanlocs, 'GSN-HydroCel-257.sfp')
    Import.Channels.Type = 'GSN-HydroCel-257.sfp';
    Import.Channels.Path = which('GSN-HydroCel-257.sfp');
else
    Import.Channels.Type = 'Geoscan';
    Import.Channels.Path = cfg.chanlocs;
end
if isempty(cfg.chanlocs)
    error('Channel locations not specified or template not found. This is required.');
end
if exist(cfg.chanlocs, 'file') == 0
    error('Channel locations file not found. This is required');
end
% --------------------------------------------------
% Setup the import configuration
Import.FileType = 'EEG';
Import.DataFile.Type = 'MFF';
Import.DataFile.Path = cfg.mff;
Import.SaveAs.Type = -1;
Import.SaveAs.Path = fullfile(cfg.savepath, 'hdeeg', sprintf('sub-%s_ses-%s_task-%s_run-%i_eeg', Import.Subject, Import.Session, Import.Task, Import.Run));
% Setup the events
Import.Events.Do = true;
if isfield(cfg, 'hypnopath')
    Import.Events.HypnoPath = cfg.hypnopath;
else
    Import.Events.HypnoPath = '';
end
if isfield(cfg, 'scoredevents')
    Import.Events.EventsPath = cfg.scoredevents;
else
    Import.Events.EventsPath = '';
end
if isfield(cfg, 'wonambipath')
    Import.Events.WonambiXMLPath = cfg.wonambipath;
else
    Import.Events.WonambiXMLPath = '';
end
% Setup the processing steps
Import.Processing.DoResample = false;
Import.Processing.DoFilter = true;
Import.Processing.FilterSettings.Fs = 500;
Import.Processing.FilterSettings.DoBandpass = true;
Import.Processing.FilterSettings.DoNotch = true;
Import.Processing.FilterSettings.Highpass = 0.1;
Import.Processing.FilterSettings.Lowpass = 60;
Import.Processing.FilterSettings.Notch = 50;
Import.Processing.FilterSettings.WindowType = 'Hamming';
Import.Processing.FilterSettings.TransitionBW = 0.2;
Import.Processing.FilterSettings.FilterOrder = 8250;
Import.Processing.DoSpectrogram = false;
Import.Processing.DoICA = false;
% --------------------------------------------------
% Import the MFF
EEG = ImportFile(Import);
% --------------------------------------------------
% Setup the EDF configuration
Import.DataFile.Type = 'GRAEL';
Import.DataFile.Path = cfg.edf;
Import.Channels.Type = 'Grael-10.sfp';
Import.Channels.Path = which('Grael-10.sfp');
Import.SaveAs.Type = -1;
Import.Processing.DoResample = true;
Import.Processing.ResampleRate = EEG.srate;
if isfield(cfg, 'edfevents')
    Import.Events.EventsPath = cfg.edfevents;
else
    Import.Events.EventsPath = '';
end
PHYS = ImportFile(Import);
% --------------------------------------------------
% Check that the SpO2 sensor is found in the dataset
idx_spo2 = strcmpi({PHYS.chanlocs.labels}, 'SpO2_OSat'); %Garry changed this from Spo2_Sat to Spo2-OSat
if ~any(idx_spo2)
    error('SpO2 sensor not found in the Grael recording')
end
% --------------------------------------------------
% Extract the first sync event
eventidx_eeg = find(strcmpi({EEG.event.type}, matlab.lang.makeValidName(cfg.mff_marker)), 1, 'first');
eventidx_phys = find(strcmpi({PHYS.event.type}, matlab.lang.makeValidName(cfg.edf_marker)), 1, 'first');
if isempty(eventidx_eeg)
    error('Could not find event marker ''%s'' in the MFF recording', cfg.mff_marker)
end
if isempty(eventidx_phys)
    error('Could not find event marker ''%s'' in the Grael recording', cfg.edf_marker)
end
latency_eeg = EEG.event(eventidx_eeg).latency;
latency_phys = PHYS.event(eventidx_phys).latency;
latency_align = latency_phys - latency_eeg;
% --------------------------------------------------
% ALIGN the recordings
if latency_align < 0
    % Add datapoints to the 'PHYS' dataset
    add = ceil(abs(latency_align));
    add = zeros(PHYS.nbchan, add, 'single');
    PHYS.data = [add, PHYS.data];
    PHYS.times = 0:1/PHYS.srate:(size(PHYS.data, 2)-1)/PHYS.srate;
    PHYS.xmax = PHYS.times(end);
    PHYS.pnts = size(PHYS.data, 2);
    PHYS.etc.T0 = datevec(datenum(PHYS.etc.T0) - size(add, 2)/(24*60*60*PHYS.srate));
    PHYS.etc.rec_startdate = datestr(PHYS.etc.T0, 'yyyy-mm-ddTHH:MM:SS');
    for i = 1:length(PHYS.event)
        PHYS.event(i).latency = PHYS.event(i).latency + size(add, 2);
    end
    latency_eeg = EEG.event(eventidx_eeg).latency;
    latency_phys = PHYS.event(eventidx_phys).latency;
    latency_align = latency_phys - latency_eeg;
    ALIGN = PHYS;
else
    % Shift the phys recording by the delay as indicated by the event markers
    ALIGN = pop_select(PHYS, 'nopoint', [1, latency_align]);
end
% --------------------------------------------------
% Further refine the alignment using the ECG signals
window = 30;
idx_samples = round(ALIGN.event(eventidx_phys).latency);
idx_samples = idx_samples:(idx_samples + window*EEG.srate);
% Extract ECG signal from EEG recording
idx_chan_eeg = find(strcmpi({EEG.chanlocs.type}, 'ECG'), 1, 'first');
if isempty(idx_chan_eeg)
    error('Could not find ECG channel in the MFF recording')
end
% Extract ECG signal from Grael recording
idx_chan_align = find(strcmpi({ALIGN.chanlocs.type}, 'ECG'), 1, 'first');
if isempty(idx_chan_align)
    error('Could not find ECG channel in the Grael recording')
end
% Compute cross covariance between the two timeseries
[c, lags] = xcov(ALIGN.data(idx_chan_align, idx_samples), EEG.data(idx_chan_eeg, idx_samples));
% Extract the lag of the maxmimum cross-covariance
[~, lag_idx] = max(abs(c));
lag = lags(lag_idx);
% Adjust the latency to align the two timeseries
latency_align = latency_align + lag;
% --------------------------------------------------
% Select the data again using this adjusted alignment
if latency_align < 0
    % Add datapoints to the 'PHYS' dataset
    add = ceil(abs(latency_align));
    add = zeros(PHYS.nbchan, add, 'single');
    PHYS.data = [add, PHYS.data];
    PHYS.times = 0:1/PHYS.srate:(size(PHYS.data, 2)-1)/PHYS.srate;
    PHYS.xmax = PHYS.times(end);
    PHYS.pnts = size(PHYS.data, 2);
    PHYS.etc.T0 = datevec(datenum(PHYS.etc.T0) - size(add, 2)/(24*60*60*PHYS.srate));
    PHYS.etc.rec_startdate = datestr(PHYS.etc.T0, 'yyyy-mm-ddTHH:MM:SS');
    for i = 1:length(PHYS.event)
        PHYS.event(i).latency = PHYS.event(i).latency + size(add, 2);
    end
    latency_eeg = EEG.event(eventidx_eeg).latency;
    latency_phys = PHYS.event(eventidx_phys).latency;
    latency_align = latency_phys - latency_eeg;
    ALIGN = PHYS;
else
    % Shift the phys recording by the delay as indicated by the event markers
    ALIGN = pop_select(PHYS, 'nopoint', [1, latency_align]);
end
% --------------------------------------------------
% Plot to confirm the alignment
if confirm
    % --------------------------------------------------
    % Start of recording
    % Extract sync-event latencies
    latency_eeg = EEG.event(eventidx_eeg).latency;
    latency_align = ALIGN.event(eventidx_phys).latency;
    % Create new figure and configure the axes
    Fig = figure();
    Fig.Position(3) = Fig.Position(4)*4;
    Ax = axes(Fig);
    Ax.FontSize = 18;
    Ax.TickDir = 'out';
    Ax.Box = 'on';
    Ax.NextPlot = 'add';
    Ax.XLabel.String = 'Start of recording (s)';
    % Indices of the samples to plot
    idx_samples = round(latency_eeg-(window/2)*EEG.srate:latency_eeg+(window/2)*EEG.srate);
    % Timeseries
    times = EEG.times(idx_samples);
    % Extract data to plot (MFF file)
    YData = EEG.data(find(strcmpi({EEG.chanlocs.type}, 'ECG'), 1, 'first'), idx_samples);
    plot(times, zscore(YData), '-k');
    % Extract data to plot (EDF file)
    YData = ALIGN.data(find(strcmpi({ALIGN.chanlocs.type}, 'ECG'), 1, 'first'), idx_samples);
    plot(times, zscore(YData), '-b');
    % Plot sync-event markers
    plot([latency_eeg, latency_eeg]./EEG.srate, [-3.1, 3.1], '--r')
    plot([latency_align, latency_align]./EEG.srate, [-3.1, 3.1], '--r')
    text(latency_eeg./EEG.srate, 3.1, ' MFF Marker ', 'HorizontalAlignment', ifelse(latency_align > latency_eeg, 'right', 'left'))
    text(latency_align./EEG.srate, 3.1, ' EDF Marker ', 'HorizontalAlignment', ifelse(latency_align > latency_eeg, 'left', 'right'), 'Color', 'b')
    Ax.OuterPosition = [0 0 0.5 1];
    % --------------------------------------------------
    % End of recording
    % Plot end of recording to see desync drift
    Ax = axes(Fig);
    Ax.FontSize = 18;
    Ax.TickDir = 'out';
    Ax.Box = 'on';
    Ax.NextPlot = 'add';
    Ax.XLabel.String = 'End of recording (s)';
    % Indices of the samples to plot
    lonidx_align = strcmpi({ALIGN.event.type}, 'lightson');
    idx_samples = round(ALIGN.event(lonidx_align).latency);
    idx_samples = (idx_samples - 3*window*EEG.srate):(idx_samples - 1*window*EEG.srate);
    idx_samples(idx_samples > EEG.pnts) = [];
    idx_samples(idx_samples > ALIGN.pnts) = [];
    % Compute cross covariance between the two timeseries
    [c, lags] = xcov(ALIGN.data(idx_chan_align, idx_samples), EEG.data(idx_chan_eeg, idx_samples));
    % Extract the lag of the maxmimum cross-covariance
    [~, lag_idx] = max(abs(c));
    lag = lags(lag_idx);
    % Timeseries
    times = EEG.times(idx_samples);
    % Extract data to plot (MFF file)
    YData = EEG.data(find(strcmpi({EEG.chanlocs.type}, 'ECG'), 1, 'first'), idx_samples);
    plot(times, zscore(YData), '-k');
    % Extract data to plot (EDF file)
    YData = ALIGN.data(find(strcmpi({ALIGN.chanlocs.type}, 'ECG'), 1, 'first'), idx_samples+lag);
    plot(times, zscore(YData), '-b');
    Ax.OuterPosition = [0.5 0 0.5 1];
    Ax.Title.String = sprintf('Lag = %.3f seconds', lag/PHYS.srate);
end


keyboard
% --------------------------------------------------
% Append or crop the aligned dataset so its the same legnth as the MFF rec
if ALIGN.pnts < EEG.pnts
    ALIGN.data = [ALIGN.data, zeros(ALIGN.nbchan, EEG.pnts-ALIGN.pnts)];
    ALIGN.pnts = size(ALIGN.data, 2);
    ALIGN.times = 0:1/ALIGN.srate:(ALIGN.pnts-1)/ALIGN.srate;
    ALIGN.xmax = ALIGN.times(end);
else
    ALIGN = pop_select(ALIGN, 'point', [1, EEG.pnts]);
end
% --------------------------------------------------
% Copy over all the physiology channels from the Greal to the MFF
pibchans_align = find(~strcmpi({ALIGN.chanlocs.type}, 'EEG'));
pibchans_eeg = find(~strcmpi({EEG.chanlocs.type}, 'EEG'));
pibchans_eeg = [pibchans_eeg; zeros(1, size(pibchans_eeg, 2))];
for i = 1:length(pibchans_align)
    label = ALIGN.chanlocs(pibchans_align(i)).labels;
    type = ALIGN.chanlocs(pibchans_align(i)).type;
    unit = ALIGN.chanlocs(pibchans_align(i)).unit;
    idx = strcmpi(label, {EEG.chanlocs.labels});
    if any(idx)
        EEG.data(idx, :) = ALIGN.data(pibchans_align(i), :);
        EEG.chanlocs(idx).labels = label;
        EEG.chanlocs(idx).type = type;
        EEG.chanlocs(idx).unit = unit;
        pibchans_eeg(2, pibchans_eeg(1, :) == find(idx)) = 1;
    else
        EEG.data(end+1, :) = ALIGN.data(pibchans_align(i), :);
        EEG.chanlocs(end+1).labels = label;
        EEG.chanlocs(end).type = type;
        EEG.chanlocs(end).unit = unit;
    end 
end
% Remove the PIB channels from the MFF recording that could not be replaced
% by the EDF recording
rm_chans = pibchans_eeg(1, pibchans_eeg(2, :) == 0);
EEG.data(rm_chans, :) = [];
EEG.chanlocs(rm_chans) = [];
EEG.nbchan = size(EEG.data, 1);
% --------------------------------------------------
% Save datasets
% First the HD-EEG as EEGLAB file
SaveDataset(EEG, 'all')
% Then convert to routing EEG (EDF file)
Settings = struct();
Settings.Path = fullfile(cfg.savepath, 'routine', sprintf('sub-%s_ses-%s_task-%s_run-%i_eeg', Import.Subject, Import.Session, Import.Task, Import.Run));
Settings.KeepPhysChans = true;
SaveTenTwentyDataset(EEG, Settings);

end
