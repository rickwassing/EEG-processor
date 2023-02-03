function stats = Proc_FasterStats(EEG, rereference)
% ---------------------------------------------------------
% Show the processing step in the command window
disp('>> BIDS: Calculating channel and epoch statistics with Faster Toolbox (DOI: 10.1016/j.jneumeth.2010.07.015)')
% ---------------------------------------------------------
% Find which channels are EEG and wich are not
eegChans = find(strcmp({EEG.chanlocs.type}, 'EEG'));
pnsChans = find(~strcmp({EEG.chanlocs.type}, 'EEG'));
% ---------------------------------------------------------
% If the EEG data needs to be rereferenced, rereference to Cz
if rereference
    refChan = find(strcmp({EEG.chanlocs.labels}, 'Cz'));
    if isempty(refChan)
        error('Reference channel ''Cz'' is not found in the ''EEG.chanlocs'' structure.')
    end
    EEG = pop_reref(EEG, refChan,...
        'exclude', pnsChans, ...
        'keepref', 'on');
else
    % Otherwise find the current reference channel
    refChan = find(strcmp({EEG.chanlocs.labels}, EEG.chanlocs(eegChans(1)).ref));
end
% ---------------------------------------------------------
% Get the epoch length
if EEG.trials > 1
    stats.epochlength = EEG.xmax - EEG.xmin + 1/EEG.srate;
    EEG = eeg_epoch2continuous(EEG);
elseif (EEG.xmax - EEG.xmin + 1/EEG.srate) <= 6
    stats.epochlength = EEG.xmax - EEG.xmin + 1/EEG.srate;
else
    stats.epochlength = 6;
end
% ---------------------------------------------------------
% Epoch the data
EEG = EpochEEG(EEG, eegChans, false, stats.epochlength);
% ---------------------------------------------------------
% Redefine 'eegChans' and 'refChan' in case the channel order changed
eegChans = find(strcmp({EEG.chanlocs.type}, 'EEG'));
pnsChans = find(~strcmp({EEG.chanlocs.type}, 'EEG')); %#ok<NASGU> 
refChan = find(strcmp({EEG.chanlocs.labels}, EEG.chanlocs(eegChans(1)).ref));
% ---------------------------------------------------------
% Calculate the polar distance to the reference electrode
if ~isempty(refChan) && length(refChan) == 1
    polarDistance = distancematrix(EEG, eegChans);
    [sortedPolarDistance, idxToSort] = sort(polarDistance(refChan, eegChans));
    [~, idxToOrig] = sort(idxToSort);
end
% ---------------------------------------------------------
% Channel-Epoch Variance
vars = squeeze(var(EEG.data(eegChans, :, :), [], 2));
if any(size(vars) == 1)
    vars = asrow(vars);
end
% -----
% For each epoch...
disp('>> BIDS: - variance')
T = now;
for ep = 1:EEG.trials
    % ... set the infinite entries to the mean of the valid variances
    vars(~isfinite(vars(:, ep)), ep) = mean(vars(isfinite(vars(:, ep)), ep));
    % -----
    % Quadratic correction for distance from reference electrode
    if ~isempty(refChan) && length(refChan) == 1
        % -----
        % Fit a polynomial to the channel variance values as a function of distance to the reference electrode
        fitcurve = polyval(polyfit(sortedPolarDistance, asrow(vars(idxToSort, ep)),2), sortedPolarDistance);
        % -----
        % Store corrected values
        stats.var(:, ep) = ascolumn(asrow(vars(:, ep)) - fitcurve(idxToOrig));
    else
        % -----
        % Otherwise, store uncorrected values
        stats.var(:, ep) = vars(:, ep);
    end
    % -----
    % Print remaining time on screen
    T = remainingTime(T, EEG.trials);
end
% ---------------------------------------------------------
% Correlation between each channel and all other channels
% -----
% Indices to use and not to use
validIdx = setdiff(eegChans, refChan);
invalidIdx = intersect(eegChans, refChan);
% -----
% For each epoch...
disp('>> BIDS: - correlation')
T = now;
for ep = 1:EEG.trials
    % ... calculate the Fisher-transformed correlation between channels
    corrs = abs(atanh(corrcoef(EEG.data(:, :, ep)')));
    corrs(invalidIdx, :) = 0;
    corrs(:, invalidIdx) = 0;
    % -----
    % Calculate the mean correlation across channels
    meanCorrs = zeros(1, length(eegChans));
    for chan = 1:length(validIdx)
        meanCorrs(validIdx(chan)) = mean(corrs(validIdx(chan), setdiff(validIdx, validIdx(chan))));
    end
    % -----
    % Set the value of invalid channels to the mean of valid channels
    meanCorrs(invalidIdx) = mean(meanCorrs(validIdx));
    % -----
    % Quadratic correction for distance from reference electrode
    if ~isempty(refChan) && length(refChan) == 1
        % -----
        % Fit a polynomial to the channel correlation values as a function of distance to the reference electrode
        fitcurve = polyval(polyfit(sortedPolarDistance, meanCorrs(idxToSort), 2), sortedPolarDistance);
        % -----
        % Store corrected values
        stats.corr(:, ep) = ascolumn(meanCorrs - fitcurve(idxToOrig));
    else
        % -----
        % Otherwise, store uncorrected values
        stats.corr(:, ep) = ascolumn(meanCorrs);
    end
    % -----
    % Print remaining time on screen
    T = remainingTime(T, EEG.trials);
end
% ---------------------------------------------------------
% Hurst exponent
% -----
stats.hurst = zeros(length(eegChans), EEG.trials);
% For each epoch...
disp('>> BIDS: - Hurst exponent')
T = now;
for ep = 1:EEG.trials
    % ... calculate the hurst exponent for each channel
    for chan = 1:length(eegChans)
        stats.hurst(chan, ep) = hurst_exponent(squeeze(EEG.data(eegChans(chan), :, ep)));
        if isinf(stats.hurst(chan, ep))
            stats.hurst(chan, ep) = NaN;
        end
    end
    % -----
    % Print remaining time on screen
    T = remainingTime(T, EEG.trials);
end
% ---------------------------------------------------------
% Calculate low and high frequency power
[stats.lfp, stats.hfp] = GetLowHighFrequencyPower(EEG);
% ---------------------------------------------------------
% Remove NaN's
for fname = {'var', 'corr', 'hurst', 'lfp', 'hfp'}
    if length(eegChans) < EEG.trials
        for chan = 1:size(stats.(fname{:}), 1)
            stats.(fname{:})(chan, isnan(stats.(fname{:})(chan, :))) = mean(stats.(fname{:})(chan, :), 'omitnan');
        end
    else
        for ep = 1:size(stats.(fname{:}), 2)
            stats.(fname{:})(isnan(stats.(fname{:})(:, ep)), ep) = mean(stats.(fname{:})(:, ep), 'omitnan');
        end
    end
end
% =========================================================
% SUBFUNCTIONS
% =========================================================
    function [LFP, HFP] = GetLowHighFrequencyPower(EEG)
        % ---------------------------------------------------------
        % Calculate frequency range
        freqRange = EEG.srate * (0:(EEG.pnts / 2)) / EEG.pnts;
        idxFreqRange = freqRange >= 0 & freqRange <= 60;
        freqRange = freqRange(idxFreqRange);
        % -----
        % Pre-allocate matrix
        powerSpectrum = nan(EEG.nbchan, sum(idxFreqRange), EEG.trials);
        % -----
        % Loop for each individual epoch
        disp('>> BIDS: - low (0.3-4 Hz) and high (25-60 Hz) frequency power')
        T0 = now;
        for i = 1:EEG.trials
            % -----
            epochStart = (i - 1) * EEG.pnts + 1;
            epochEnd = i * EEG.pnts;
            % -----
            % run the fft
            if any(isnan(EEG.data(:, epochStart:epochEnd)))
                powerSpectrum(:, :, i) = NaN;
            else
                fft_estimate = abs(fft(EEG.data(:, epochStart:epochEnd), [], 2) / EEG.pnts);
                fft_estimate = fft_estimate(:, 1:EEG.pnts / 2 + 1);
                fft_estimate(:, 2:end-1) = 2. * fft_estimate(:, 2:end-1);
                powerSpectrum(:, :, i) = fft_estimate(:, idxFreqRange);
            end
            % -----
            % Print remaining time on screen
            T0 = remainingTime(T0, EEG.trials);
        end
        % -----
        % Average across frequency ranges of interest
        LFrange = freqRange >= 0.3  &  freqRange <= 4;
        HFrange = freqRange >= 25  &  freqRange <= 60;
        LFP = squeeze(mean(powerSpectrum(:, LFrange, :), 2, 'omitnan'));
        HFP = squeeze(mean(powerSpectrum(:, HFrange, :), 2, 'omitnan'));
        if any(size(LFP) == 1)
            LFP = asrow(LFP);
        end
        if any(size(HFP) == 1)
            HFP = asrow(HFP);
        end
    end
% =========================================================
    function EEG = EpochEEG(EEG, eegChans, reject, epochlength)
        % ---------------------------------------------------------
        % Insert NaN's for any rejected events
        if reject
            events = EEG.event(regexpIdx(lower({EEG.event.type}), 'reject'));
            times = EEG.times.*EEG.srate;
            EEG.data(:, eegevent2idx(events, times)) = NaN;
        end
        % ---------------------------------------------------------
        % Epoch the data
        EEG.data = EEG.data(eegChans, :);
        EEG.nbchan = length(eegChans);
        EEG.chanlocs = EEG.chanlocs(eegChans);
        EEG.trials = floor(EEG.pnts ./ (epochlength*EEG.srate));
        EEG.pnts = epochlength*EEG.srate;
        EEG.xmax = epochlength-1/EEG.srate;
        EEG.data = EEG.data(:, 1:EEG.trials*EEG.pnts);
        EEG.data = reshape(EEG.data, length(eegChans), EEG.pnts, EEG.trials);
    end
% =========================================================
end
