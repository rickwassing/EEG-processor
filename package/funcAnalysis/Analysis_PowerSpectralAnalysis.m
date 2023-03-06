function [ArgOut, Next, Warnings] = Analysis_PowerSpectralAnalysis(Settings)
% ---------------------------------------------------------
% Initialize
ArgOut = [];
Next = 'none';
Warnings = [];
% ---------------------------------------------------------
% Get data path
[~, filename] = fileparts(Settings.InputFilePath);
% ---------------------------------------------------------
% Check if dataset exists
if exist(Settings.InputFilePath) == 0 %#ok<EXIST> 
    Warnings = [Warnings; {sprintf('Could not load dataset ''%s'', file not found.', filename)}];
    Warnings = [Warnings; {'-----'}];
    return
end
% ---------------------------------------------------------
% Load data
disp('>> BIDS: Loading dataset')
EEG = LoadDataset(Settings.InputFilePath, 'all');
% Initialize the output 
KeyVals = filename2struct(filename);
PSD = struct();
PSD.filename = [Settings.Filename, '.mat'];
PSD.filepath = [Settings.ProtocolPath, '/derivatives/EEG-output-fstlvl/sub-', KeyVals.sub, '/ses-', KeyVals.ses];
PSD.subject = KeyVals.sub;
PSD.session = KeyVals.ses;
PSD.task = KeyVals.task;
PSD.run = KeyVals.run;
PSD.group = '';
PSD.condition = '';
PSD.nbchan = EEG.nbchan;
PSD.trials = EEG.trials;
PSD.srate = EEG.srate;
PSD.ref = EEG.ref;
PSD.history = EEG.history;
% ---------------------------------------------------------
% Define parameters for the analysis
% Channel selection
ChanSel = strcmpi({EEG.chanlocs.type}, 'EEG');
% Window length in samples
WinLength = Settings.Window.Length * EEG.srate;
% Check if the window length is smaller than the epoch length
if WinLength > EEG.pnts
    fprintf('>> BIDS: Warning. The window length was longer than the number of datapoints. Window length was adjusted to %.3f seconds.\n', EEG.pnts/EEG.srate)
    Warnings = [Warnings; {sprintf('Window length was longer than the number of datapoints. Window length was adjusted to %.3f seconds.\n', EEG.pnts/EEG.srate)}];
    Warnings = [Warnings; {'-----'}];
    WinLength = EEG.pnts;
end
% Define window step
WinStep = floor(WinLength * (Settings.Window.Overlap/100));
% ---------------------------------------------------------
% If the settings contain outlier channels, interpolate those first
if isfield(Settings, 'Outliers')
    fprintf('>> BIDS: Interpolating %i outlier channels\n', length(Settings.Outliers))
    EEG = eeg_interp(EEG, find(...
        ismember({EEG.chanlocs.labels}, Settings.Outliers) ...
        ));
end
% ---------------------------------------------------------
fprintf('>> BIDS: Running power-spectral analysis using Welch''s method on %i trials with windows of %.3f sec and %.1f%% overlap.\n', EEG.trials, WinLength/EEG.srate, 100*WinStep/WinLength)
% ---------------------------------------------------------
% Run
for i = 1:EEG.trials
    Data = squeeze(EEG.data(ChanSel, :, i));
    [Pow, Freq] = pwelch(Data', WinLength, WinStep, max([256, 2^nextpow2(WinLength)]), EEG.srate);
    if i == 1
        % Initialize the output matrix
        PSD.data = nan(sum(ChanSel), length(Freq), EEG.trials);
    end
    PSD.data(:, :, i) = Pow';
    PSD.freqs = Freq;
end
PSD.freqstep = mean(diff(PSD.freqs));
% ---------------------------------------------------------
% Calculate the absolute and normalized power in user-specified frequency bands
AllFreqs = cat(1, Settings.FreqDef.band);
cnt = 0;
for i = 1:length(Settings.FreqDef)
    % ---------------------------------------------------------
    % Get indices of this frequency band
    idxFreq = PSD.freqs >= Settings.FreqDef(i).band(1) & PSD.freqs < Settings.FreqDef(i).band(2);
    if ~any(idxFreq)
        continue
    end
    % ---------------------------------------------------------
    % increase counter
    cnt = cnt+1;
    % ---------------------------------------------------------
    % Integrate absolute power
    fprintf('>> BIDS: Integrating power spectral density for frequency band ''%s'' between %.1f - %.1f Hz.\n', Settings.FreqDef(i).label, Settings.FreqDef(i).band(1), Settings.FreqDef(i).band(2))
    PSD.bands(cnt).label = sprintf('%s', Settings.FreqDef(i).label);
    PSD.bands(cnt).type = 'absolute';
    PSD.bands(cnt).freqrange = Settings.FreqDef(i).band;
    PSD.bands(cnt).data = squeeze(sum(PSD.data(:, idxFreq, :), 2) .* PSD.freqstep);
    % ---------------------------------------------------------
    % Extract the frequency indices for normalization (across all freqs or within freq band)
    fprintf('>> BIDS: Normalizing %s power relative to: ', Settings.FreqDef(i).label);
    if Settings.Norm.AcrossFreqBands
        fprintf('total power in the frequencies %.1f - %.1f Hz ', min(AllFreqs(:)), max(AllFreqs(:)));
        idxNormFreq = PSD.freqs >= min(AllFreqs(:)) & PSD.freqs < max(AllFreqs(:));
    else
        fprintf('total power in the frequencies %.1f - %.1f Hz ', Settings.FreqDef(i).band(1), Settings.FreqDef(i).band(2));
        idxNormFreq = idxFreq;
    end
    % ---------------------------------------------------------
    % Caluclate normalization factor i.e. integrate across frequencies
    NormFactor = sum(PSD.data(:, idxNormFreq, :), 2) .* PSD.freqstep;
    % Take the average across channels if requested
    if Settings.Norm.AcrossChannels
        fprintf('averaged across channels ');
        NormFactor = mean(NormFactor, 1);
    else
        fprintf('for each individual channel ');
    end
    % Take the average across trials if requested
    if Settings.Norm.AcrossTrials
        fprintf('and averaged across %i trials', PSD.trials);
        NormFactor = mean(NormFactor, 3);
    else
        fprintf('and for each individual trial (%i trials)', PSD.trials);
    end
    fprintf('\n');
    % Re-expand the normalization factor so it is the same size as the data
    if size(NormFactor, 1) == 1
        NormFactor = repmat(NormFactor, size(PSD.data, 1), 1, 1);
    end
    if size(NormFactor, 3) == 1
        NormFactor = repmat(NormFactor, 1, 1, size(PSD.data, 3));
    end
    % Normalize the power relative to the normalization factor
    cnt = cnt+1;
    PSD.bands(cnt).label = sprintf('%s', Settings.FreqDef(i).label);
    PSD.bands(cnt).type = 'normalized';
    PSD.bands(cnt).freqrange = Settings.FreqDef(i).band;
    PSD.bands(cnt).data = squeeze((sum(PSD.data(:, idxFreq, :), 2) .* PSD.freqstep) ./ NormFactor);
end
% ---------------------------------------------------------
% Calculate the mean/median across trials or squeeze the dataset
switch Settings.EpochAverage
    case 'mean'
        fprintf('>> BIDS: calculating the mean power spectral density estimates across trials.\n')
        PSD.data = squeeze(mean(PSD.data, 3));
        for i = 1:length(PSD.bands)
            PSD.bands(i).data = squeeze(mean(PSD.bands(i).data, 3));
        end
    case 'median'
        fprintf('>> BIDS: calculating the mean power spectral density estimates across trials.\n')
        PSD.data = squeeze(median(PSD.data, 3));
        for i = 1:length(PSD.bands)
            PSD.bands(i).data = squeeze(median(PSD.bands(i).data, 3));
        end
    otherwise
        % Try to squeeze the data, i.e. when there was only one trial
        PSD.data = squeeze(PSD.data);
        for i = 1:length(PSD.bands)
            PSD.bands(i).data = squeeze(PSD.bands(i).data);
        end
end
% ---------------------------------------------------------
% Save some more info
PSD.nbchan = sum(ChanSel);
PSD.trials = size(PSD.data, 3);
PSD.chanlocs = EEG.chanlocs(ChanSel);
PSD.chaninfo = EEG.chaninfo;
% ---------------------------------------------------------
% JSON
PSD.etc.JSON = struct();
PSD.etc.JSON.Description = 'Power spectral density estimate of the EEG signal, using Welch''s overlapped segment averaging estimator.';
PSD.etc.JSON.Sources = fullpath2bidsuri(Settings.ProtocolPath, [EEG.filepath, '/', EEG.filename]);
PSD.etc.JSON.TaskName = KeyVals.task;
PSD.etc.JSON.EEGReference = EEG.etc.JSON.EEGReference;
PSD.etc.JSON.EEGChannelCount = PSD.nbchan;
PSD.etc.JSON.ECGChannelCount = 0;
PSD.etc.JSON.EMGChannelCount = 0;
PSD.etc.JSON.EOGChannelCount = 0;
PSD.etc.JSON.MiscChannelCount = 0;
PSD.etc.JSON.TrialCount = PSD.trials;
PSD.etc.JSON.SpectralAnalysis = struct();
PSD.etc.JSON.SpectralAnalysis.ChannelSelection = {PSD.chanlocs.labels};
PSD.etc.JSON.SpectralAnalysis.SpectrogramType = 'pwelch';
PSD.etc.JSON.SpectralAnalysis.FrequencyStep = mean(abs(diff(PSD.freqs)));
PSD.etc.JSON.SpectralAnalysis.MaximumFrequency = PSD.freqs(end);
PSD.etc.JSON.SpectralAnalysis.WindowLength = Settings.Window.Length;
PSD.etc.JSON.SpectralAnalysis.WindowOverlap = Settings.Window.Overlap;
PSD.etc.JSON.SpectralAnalysis.Norm.AcrossFreqBands = ifelse(Settings.Norm.AcrossFreqBands, 1, 0);
PSD.etc.JSON.SpectralAnalysis.Norm.AcrossChannels = ifelse(Settings.Norm.AcrossChannels, 1, 0);
PSD.etc.JSON.SpectralAnalysis.Norm.AcrossTrials = ifelse(Settings.Norm.AcrossTrials, 1, 0);
PSD.etc.JSON.SpectralAnalysis.EpochAverage = Settings.EpochAverage;
% ---------------------------------------------------------
% Store history
PSD = storeHistory(PSD, 'Analysis_PowerSpectralAnalysis', Settings);
% ---------------------------------------------------------
% Save file to disk
PSD = SaveDataset(PSD, 'matrix');
% ---------------------------------------------------------
% Set output
ArgOut = PSD;
% What step to do next?
Next = 'AddFile';

end