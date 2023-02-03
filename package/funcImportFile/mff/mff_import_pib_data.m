function EEG = mff_import_pib_data(EEG, mffData)

if length(mffData.signal_binaries) == 1
    return
end

npibchans = mffData.signal_binaries(2).num_channels;
T = now;
for pib_channel = 1:npibchans
     
    % get all the physiology data
    temp_data = mff_import_signal_binary(mffData.signal_binaries(2), pib_channel, 'all');
    EEG.data(end+1, :) = temp_data.samples;
    
    % Display time remaining
    T = remainingTime(T, npibchans);
end

EEG.nbchan = EEG.nbchan+npibchans;