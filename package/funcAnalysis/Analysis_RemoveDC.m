function EEG = Analysis_RemoveDC(EEG, Settings)

if Settings.DoRemoveDC
    DCInterval = Settings.DCInterval;
    DCInterval(DCInterval < EEG.xmin) = EEG.xmin;
    DCInterval(DCInterval > EEG.xmax) = EEG.xmax;
    fprintf('>> BIDS: Removing DC offset between %.3f and %.3f seconds in file ''%s''\n', DCInterval(1), DCInterval(2), EEG.setname);
    EEG = pop_rmbase(EEG, DCInterval*1000);
end

end