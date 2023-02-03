function EEG = Proc_Resample(EEG, Settings)

if Settings.DoResample
    fprintf('>> BIDS: Resampling dataset from %i Hz to %i Hz\n', EEG.srate, Settings.ResampleRate)
    T = now;
    EEG = pop_resample(EEG, Settings.ResampleRate);
    % ID #0004
    EEG.etc.JSON.SamplingFrequency = Settings.ResampleRate;
    fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
end

end