function [EEG, Warnings] = Proc_RejectChannels(EEG, Settings, RejChans, Warnings)

if isempty(RejChans)
    if isfield(EEG.etc, 'rej_channels')
        EEG.etc = rmfield(EEG.etc, 'rej_channels');
    end
    Warnings = [Warnings; {'Did not remove any channels, rejected channel list is empty'}];
    Warnings = [Warnings; {'-----'}];
else
    % Check to interpolate or remove the channels
    if Settings.DoInterpolate
        % Interpolate
        disp('>> BIDS: Interpolating rejected channels')
        EEG = eeg_interp(EEG, find(...
            ismember({EEG.chanlocs.labels}, RejChans) ...
            ));
        EEG.etc.interp_channels = EEG.etc.rej_channels;
    else
        % Remove
        disp('>> BIDS: Removing rejected channels')
        EEG = pop_select(EEG, 'nochannel', RejChans);
        EEG.etc.removed_channels = EEG.etc.rej_channels;
    end
    EEG.etc = rmfield(EEG.etc, 'rej_channels');
end
% Update the JSON struct
EEG.etc.JSON.EEGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'EEG'));
EEG.etc.JSON.ECGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'ECG'));
EEG.etc.JSON.EMGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'EMG'));
EEG.etc.JSON.EOGChannelCount = sum(strcmpi({EEG.chanlocs.type}, 'EOG') | strcmpi({EEG.chanlocs.type}, 'VEOG') | strcmpi({EEG.chanlocs.type}, 'HEOG'));
EEG.etc.JSON.MiscChannelCount = EEG.nbchan - ...
    EEG.etc.JSON.EEGChannelCount - ...
    EEG.etc.JSON.ECGChannelCount - ...
    EEG.etc.JSON.EMGChannelCount - ...
    EEG.etc.JSON.EOGChannelCount;

end