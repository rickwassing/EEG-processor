function Settings = DefaultSpindleDetectionSettings(EEG, algorithm)

switch lower(algorithm)
    case 'lacourse'
        Settings.standard_sampleRate = EEG.srate;
        Settings.spindleNoArt = 0;
        % Sigma based thresholds
        Settings.absSigPow_Th = 1.25; % absSigPow threshold (sigma power log10 transformed)
        Settings.relSigPow_Th = 1.6;  % relSigPow (z-score of relative sigma power from a clean 30 sec around the current window)
        % Correlation and covariance thresholds
        Settings.sigCov_Th = 1.3;  % sigmaCov (z-score of the covariance of sigma from a clean 30 sec around the current window)
        Settings.sigCorr_Th = 0.69; % sigmaCorr (correlation of sigma signal)
        % Spindle definition
        Settings.minDurSpindleSec = 0.3; % minimum duration of spindle in sec
        Settings.maxDurSpindleSec = 3; % maximum duration of spindle in sec
        % Context Classifier definition (Slow ratio)
        % Slow ratio filter
        Settings.lowFreqLow = 0.5; % frequency band of delta + theta
        Settings.lowFreqHigh = 8.0; % frequency band of delta + theta
        Settings.highFreqLow = 16.0; % frequency band of beta
        Settings.highFreqHigh = 30.0; % frequency band of beta.
        % Detection In Context
        Settings.slowRat_Th = 0.9; % slow ratio threshold for the spindle spectral context
        % Sigma filter definition
        Settings.sigmaFreqLow  = 11.0; % sigma frequency band low
        Settings.sigmaFreqHigh = 16.0; % sigma frequency band high
        Settings.fOrder = 20;   % filter order for the sigma band
        % Baseline filter definition for relative sigma power
        Settings.totalFreqLow = 4.5; % frequency band of the broad band
        Settings.totalFreqHigh = 30.0; % frequency band of the broad band
        % Sliding windows definition
        % Detection and PSA window
        Settings.winLengthSec = 0.3;  % window length in sec
        Settings.WinStepSec = 0.1; % window step in sec
        Settings.ZeroPadSec = 2; % zero padding length in sec
        Settings.bslLengthSec = 30;   % baseline length to compute the z-score of rSigPow and sigmaCov
        % Parameter settings
        Settings.eventNameAbsPowValue = 'a7AbsPowValue'; % event name for warnings
        % Settings used in a7subRelSigPow.m
        Settings.eventNameRelSigPow = 'a7RelSigPow'; % event name for warnings
        Settings.lowPerctRelSigPow = 10; % low percentile to compute the STD and median of both thresholds
        Settings.highPerctRelSigPow = 90; % high percentile to compute the STD and median of both thresholds
        Settings.useLimPercRelSigPow = 1; % Consider only the baseline included in the percentile selected
        Settings.useMedianPSAWindRelSigPow = 0; % To use the median instead of the mean to compute the threshold.
        % Settings used in a7subSigmaCov.m
        Settings.eventNameSigmaCov = 'a7SigmaCov'; % event name for warnings
        Settings.lowPerctSigmaCov = 10; % low percentile to compute the STD and median of both thresholds
        Settings.highPerctSigmaCov = 90; % high percentile to compute the STD and median of both thresholds
        Settings.filterOrderSigmaCov = 20;
        Settings.useLimPercSigmaCov = 1; % Consider only the baseline included in the percentile selected
        Settings.removeDeltaFromRawSigmaCov = 0; % To filter out the delta signal from the raw signal to compute the covariance
        Settings.useMedianWindSigmaCov = 0; % On: Use the median to the bsl normlization, Off: Use the mean value
        Settings.useLog10ValNoNegSigmaCov = 1; % On: Use log10 distribution (It is more similar to normal distribution)
        % Settings used in a7subSigmaCorr.m
        Settings.removeDeltaFromRawSigCorr = 0;% To filter out the delta signal from the raw signal to compute the correlation
        % Settings used in a7subTurnOffDetSlowRatio.m
        Settings.eventNameSlowRatio = 'a7SlowRatio';  % event name for warnings
        Settings.useMedianWindSlowRatio = 0; % On: Use the median to the bsl normlization, Off: Use the mean value
        Settings.useLog10ValNoNegSlowRatio = 1; % On: Use log10 distribution (It is more similar to normal distribution)
        % Choose the sleep stage, all by default
        Settings.bslSleepStaging = '';
        Settings.inContOn = 0;
end

end