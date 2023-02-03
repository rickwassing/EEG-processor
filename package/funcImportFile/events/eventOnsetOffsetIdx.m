function idx = eventOnsetOffsetIdx(EEG, eventType)

idx = false(1, EEG.pnts);
[~, idxEvent] = pop_selectevent(EEG, 'type', eventType);
eventOnOffset = [[EEG.event(idxEvent).latency]', [EEG.event(idxEvent).latency]' + [EEG.event(idxEvent).duration]' - 1];

for ev = 1:size(eventOnOffset, 1)
    if strcmpi(EEG.event(idxEvent(ev)).type, 'boundary')
        continue
    end
    idx(eventOnOffset(ev, 1):eventOnOffset(ev, 2)) = true;
end

end