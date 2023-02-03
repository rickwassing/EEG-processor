function EEG = Proc_RejectNonCranialChannels(EEG, Settings)

% check what system this recording is
[bool, system] = ishdeeg({EEG.chanlocs.labels});
if ~bool
    fprintf('>> BIDS: Did not remove non-cranial channels, system ''%s'' is not supported\n', system)
    return
end
fprintf('>> BIDS: Removing non-cranial channels\n')
% Get the hard-coded list of included channels
incl = hdeeg_scalpchannels(system);
% Get the list of all EEG channels
eegchans = {EEG.chanlocs(strcmpi({EEG.chanlocs.type}, 'EEG')).labels};
% Get the list of all EEG channels to remove
excl = setdiff(eegchans, incl);
% Go ahead and remove them
EEG = pop_select(EEG, 'nochannel', excl);
% Any rejected or interpolated channel in the excluded list is no longer necessary
if isfield(EEG.etc, 'rej_channels')
    idx = ismember(EEG.etc.rej_channels, excl);
    if any(idx)
        EEG.etc.rej_channels(idx) = [];
    end
    if isempty(EEG.etc.rej_channels)
        EEG.etc = rmfield(EEG.etc, 'rej_channels');
    end
end
if isfield(EEG.etc, 'interp_channels')
    idx = ismember(EEG.etc.interp_channels, excl);
    if any(idx)
        EEG.etc.interp_channels(idx) = [];
    end
    if isempty(EEG.etc.interp_channels)
        EEG.etc = rmfield(EEG.etc, 'interp_channels');
    end
end
% Update the JSON
EEG.etc.JSON.EEGChannelCount = length(incl);

end
