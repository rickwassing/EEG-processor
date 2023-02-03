function idx = eventOnsetOffsetSamples(EEG, eventType)

[~, idx] = pop_selectevent(EEG, 'type', eventType);
idx(strcmpi({EEG.event(idx).type}, 'boundary')) = [];
idx = [[EEG.event(idx).latency]', [EEG.event(idx).latency]' + [EEG.event(idx).duration]' - 1];

end