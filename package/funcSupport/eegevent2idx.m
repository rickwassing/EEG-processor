function idx = eegevent2idx(events, times)

idx = false(size(times));

for i = 1:length(events)
    onset  = find(times > events(i).latency, 1, 'first')-1;
    offset = find(times < (events(i).latency + events(i).duration), 1, 'last');
    if isempty(onset) || isempty(offset)
        continue
    end
    if onset < 1
        onset = 1;
    end
    idx(onset:offset) = true;
end

end