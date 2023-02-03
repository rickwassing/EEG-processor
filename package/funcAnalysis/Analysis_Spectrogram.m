function [EEG, Warnings] = Analysis_Spectrogram(EEG, Settings, RejChans, Warnings)

% Initialize empty vectors
EEG.specdata = [];
EEG.specchans = [];
EEG.specfreqs = [];
EEG.spectimes = [];

if Settings.DoSpectrogram
    try
        fprintf('>> BIDS: Calculating time-frequency spectrogram on file ''%s''\n', EEG.setname)
        T = now;
        % Remove rejected channels
        IncludeChans = setdiff(Settings.SpectrogramSettings.ChanSel, RejChans);
        % If there are less than 4 channels left, we cannot continue, too little data
        if isempty(IncludeChans)
            disp('Did not calculate spectrogram, all channels were rejected')
            Warnings = [Warnings; {'Did not calculate spectrogram, all channels were rejected'}];
            Warnings = [Warnings; {'-----'}];
            return
        end
        % Try to find all the good 10-20 channels
        IncludeChanIdx = find(ismember({EEG.chanlocs.labels}, IncludeChans));
        % If not all are found, trow a warning
        if length(IncludeChanIdx) ~= length(IncludeChans)
            disp('Did not calculate spectrogram, expected channels not found')
            Warnings = [Warnings; {'Did not calculate spectrogram, expected channels not found'}];
            Warnings = [Warnings; {'-----'}];
            return
        end
        % We're good to go, lets define the parameters and run the analysis
        FT_EEG = eeglab2fieldtrip( ...
            eeg_epoch2continuous(pop_select(EEG, 'channel', {EEG.chanlocs(IncludeChanIdx).labels})), ...
            'preprocessing', 'none');
        cfg = [];
        cfg.output = 'pow';
        cfg.channel = {EEG.chanlocs(IncludeChanIdx).labels};
        cfg.method = ifelse(strcmpi(Settings.SpectrogramSettings.SpectrogramType, 'Multitaper'), 'mtmconvol', 'wavelet');
        cfg.pad = 'nextpow2';
        cfg.taper = 'hanning';
        cfg.width = Settings.SpectrogramSettings.Cycles;
        cfg.foi = 1/range([EEG.xmin, EEG.xmax+1/EEG.srate])+Settings.SpectrogramSettings.FreqStep:Settings.SpectrogramSettings.FreqStep:Settings.SpectrogramSettings.MaxFreq;
        cfg.toi = FT_EEG.time{1, 1}(1):Settings.SpectrogramSettings.TimeStep:FT_EEG.time{1, 1}(end);
        cfg.wavelen = 1./cfg.foi;
        cfg.t_ftimwin = min([ones(1, length(cfg.foi))*Settings.SpectrogramSettings.Cycles; range([EEG.xmin, EEG.xmax+1/EEG.srate])./cfg.wavelen])./cfg.foi;
        TFA = ft_freqanalysis(cfg, FT_EEG);
        % Weirdly, the TFA timeseries have slight inconsistencies, so round to the neirest millisecond
        TFA.time = round(TFA.time.*1000)./1000;
        for j = 1:EEG.trials
            idx = ...
                TFA.time >= round((EEG.xmin + (j-1)*range([EEG.xmin, EEG.xmax+1/EEG.srate])).*1000)./1000 & ...
                TFA.time < round((EEG.xmin + j*range([EEG.xmin, EEG.xmax+1/EEG.srate])).*1000)./1000;
            if j == 1
                EEG.specdata = nan(length(TFA.label), length(TFA.freq), sum(idx), EEG.trials, 'single');
            end
            EEG.specdata(:, :, :, j) = single(TFA.powspctrm(:, :, idx));
        end
        EEG.specdata = squeeze(EEG.specdata); %<chans, freqs, times, trials>
        EEG.specchans = TFA.label;
        EEG.specfreqs = cfg.foi;
        EEG.spectimes = EEG.xmin:Settings.SpectrogramSettings.TimeStep:EEG.xmax;
        if Settings.SpectrogramSettings.DoBaselineNorm
            BaselineIdx = EEG.spectimes >= Settings.SpectrogramSettings.BaselineInterval(1) & EEG.spectimes <= Settings.SpectrogramSettings.BaselineInterval(2);
            EEG.specnormmethod = Settings.SpectrogramSettings.BaselineMethod;
            EEG.specnormvals.mu = mean(EEG.specdata(:, :, BaselineIdx, :), 3, 'omitnan');
            EEG.specnormvals.sd = sqrt(nanvar(EEG.specdata(:, :, BaselineIdx, :), [], 3));
            % Create normalization function
            switch Settings.SpectrogramSettings.BaselineMethod
                case 'absolute'
                    EEG.specnormfnc = @(data, mu) data - repmat(mu, [1, 1, size(data, 3), 1]);
                case 'relative'
                    EEG.specnormfnc = @(data, mu) data ./ repmat(mu, [1, 1, size(data, 3), 1]);
                case 'relchange'
                    EEG.specnormfnc = @(data, mu) (data - repmat(mu, [1, 1, size(data, 3), 1])) ./ repmat(mu, [1, 1, size(data, 3), 1]);
                case 'normchange'
                    EEG.specnormfnc = @(data, mu) (data - repmat(mu, [1, 1, size(data, 3), 1])) ./ (data + repmat(mu, [1, 1, size(data, 3), 1]));
                case 'db'
                    EEG.specnormfnc = @(data, mu) 10 * log10(data ./ repmat(mu, [1, 1, size(data, 3), 1]));
                case 'zscore'
                    EEG.specnormfnc = @(data, mu, sd) (data - repmat(mu, [1, 1, size(data, 3), 1])) ./ repmat(sd, [1, 1, size(data, 3), 1]);
            end
        else
            EEG.specnormmethod = 'none';
        end
        % Print processing time
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
    catch ME
        fprintf('>> BIDS: Warning, an error occured during the calculation of the spectrogram\n')
        printME(ME)
        Warnings = [Warnings; {'An error occured during the calculation of the spectrogram'}];
        Warnings = [Warnings; {'-----'}];
    end
else
    fprintf('>> BIDS: No spectrogram calculated.\n')
end

end
