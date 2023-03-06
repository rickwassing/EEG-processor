function EEG = forceValidEventType(EEG)

% Forces the event type string to be alphanumeric, lower-case and valid
% matlab variable names
if ~isfield(EEG, 'event')
    return
end
% Make sure there is at least one event
if isempty(EEG.event)
    EEG.event = struct('latency', 0.5, 'duration', 0, 'type', 'start', 'id', 1, 'is_reject', false);
end
if ~isfield(EEG.event, 'latency')
    error('Missing field ''latency'' in ''EEG.event'' structure')
end
% Make sure there is a 'duration' field
if ~isfield(EEG.event, 'duration')
    for i = 1:length(EEG.event)
        EEG.event(i).duration = 0;
    end
end
% Make sure there is a 'type' field
if ~isfield(EEG.event, 'type')
    for i = 1:length(EEG.event)
        EEG.event(i).type = 'unknown';
    end
end
% Make sure there is a 'id' field
if ~isfield(EEG.event, 'id')
    for i = 1:length(EEG.event)
        EEG.event(i).id = i;
    end
end
% Make sure there is a 'is_reject' field
if ~isfield(EEG.event, 'is_reject')
    for i = 1:length(EEG.event)
        EEG.event(i).is_reject = false;
    end
end
for i = 1:length(EEG.event)
    if isnumeric(EEG.event(i).type)
        EEG.event(i).type = num2str(EEG.event(i).type);
    end
    EEG.event(i).type(~isstrprop(EEG.event(i).type, 'alphanum')) = '';
    EEG.event(i).type = matlab.lang.makeValidName(lower(EEG.event(i).type));
    if isempty(EEG.event(i).type)
        EEG.event(i).type = 'unknown';
    end
end
% Check that each event has a unique ID
if length(unique([EEG.event.id])) ~= length(EEG.event)
    for i = 1:length(EEG.event)
        EEG.event(i).id = i;
    end
end

end
