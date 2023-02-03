function Events = selectEventsByTime(Events, StartTime, EndTime)

idx = ...
    (...
    [Events.latency] >= StartTime & ...
    [Events.latency] < EndTime ...
    ) | (...
    [Events.latency]+[Events.duration] > StartTime & ...
    [Events.latency]+[Events.duration] <= EndTime ...
    ) | (...
    [Events.latency] <= StartTime & ...
    [Events.latency]+[Events.duration] >= EndTime ...
    );

Events = Events(idx);

end