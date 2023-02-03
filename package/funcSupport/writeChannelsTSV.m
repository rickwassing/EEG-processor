function writeChannelsTSV(EEG, ChannelFilename)

if ~isfield(EEG.chanlocs, 'labels')
    return
end
if ~isfield(EEG.chanlocs, 'type')
    for i = 1:length(EEG.chanlocs)
        EEG.chanlocs(i).type = 'OTHER';
    end
end
if ~isfield(EEG.chanlocs, 'unit')
    for i = 1:length(EEG.chanlocs)
        EEG.chanlocs(i).unit = 'unknown';
    end
end
if ~isfield(EEG.chanlocs, 'ref')
    for i = 1:length(EEG.chanlocs)
        EEG.chanlocs(i).ref = 'unknown';
    end
end
Channels = table();
Channels.name = ascolumn({EEG.chanlocs.labels});
Channels.type = ascolumn({EEG.chanlocs.type});
Channels.units = ascolumn({EEG.chanlocs.unit});
if isfield(EEG, 'srate')
    Channels.sampling_frequency = repmat(EEG.srate, length(EEG.chanlocs), 1);
else
    Channels.sampling_frequency = repmat({'n/a'}, length(EEG.chanlocs), 1);
end
for i = 1:length(EEG.chanlocs)
    if iscell(EEG.chanlocs(i).ref)
        Channels.reference{i, 1} = strjoin(EEG.chanlocs(i).ref, ' ');
    else
        Channels.reference{i, 1} = EEG.chanlocs(i).ref;
    end
end
% First, set all channels to be "good" and description to "n/a"
Channels.status = repmat({'good'}, length(EEG.chanlocs), 1);
Channels.description = repmat({'n/a'}, length(EEG.chanlocs), 1);
% Second, if there are bad channels, set them to "bad"
if isfield(EEG.etc, 'rej_channels')
    Channels.status(ismember(Channels.name, EEG.etc.rej_channels)) = {'bad'};
end
% Third, if there are interpolated channels, set the description to "interpolated"
if isfield(EEG.etc, 'interp_channels')
    Channels.description(ismember(Channels.name, EEG.etc.interp_channels)) = {'interpolated'};
end
% empty cells are not allowed
Channels.name(ismissing(Channels.name)) = {'n/a'};
Channels.type(ismissing(Channels.type)) = {'n/a'};
Channels.units(ismissing(Channels.units)) = {'n/a'};
Channels.reference(ismissing(Channels.reference)) = {'n/a'};
writetable(Channels, ChannelFilename, 'FileType', 'text', 'Delimiter', '\t')
end
