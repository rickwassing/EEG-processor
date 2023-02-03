function EEG = mff_import_eeg_data(EEG, mffData)

% calculate total size and pre-allocate
EEG.data = zeros(EEG.nbchan, EEG.pnts, 'single');

% fill the EEG.data
T = now; cnt = 0;
for chan = 1:EEG.nbchan
    % convert the channel-name to channel-index
    chanlabel = EEG.chanlocs(chan).labels;
    switch chanlabel
        case 'Cz'
            chan = 257;
        otherwise
            chan = str2double(chanlabel(2:end));
    end
    % Up the counter
    cnt = cnt+1;
    
    % get all the data
    temp_data = mff_import_signal_binary(mffData.signal_binaries(1), chan, 'all');
    EEG.data(cnt, :) = temp_data.samples;

    % Display time remaining
    T = remainingTime(T, EEG.nbchan);
end