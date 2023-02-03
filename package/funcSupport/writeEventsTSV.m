function writeEventsTSV(EEG, EventsFilename)

Events = table();
Events.onset = 0;
Events.duration = 0;
Events.trial_type = {'start'};
if isempty(EEG.event) || ~isstruct(EEG.event)
    writetable(Events, EventsFilename, 'FileType', 'text', 'Delimiter', '\t');
    return
end
if ~isfield(EEG.event, 'latency') || ~isfield(EEG.event, 'duration') || ~isfield(EEG.event, 'type')
    writetable(Events, EventsFilename, 'FileType', 'text', 'Delimiter', '\t');
    return
end
if isempty([EEG.event.latency])
    writetable(Events, EventsFilename, 'FileType', 'text', 'Delimiter', '\t');
    return
end

Events = table();
Events.onset = ascolumn([EEG.event.latency]./EEG.srate);
Events.duration = ascolumn([EEG.event.duration]./EEG.srate);
if isfield(EEG.event, 'is_reject')
    Events.trial_type = ascolumn(cellfun(@(label, isreject) ifelse(isreject, ['artifact_', label], label), {EEG.event.type}, {EEG.event.is_reject}, 'UniformOutput', false));
else
    Events.trial_type = ascolumn({EEG.event.type});
end
% Sort
[~, idx] = sort(Events.onset);
Events = Events(idx, :);
% Write
writetable(Events, EventsFilename, 'FileType', 'text', 'Delimiter', '\t');

end