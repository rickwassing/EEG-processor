function EEG = forceValidEventType(EEG)

% Forces the event type string to be alphanumeric, lower-case and valid
% matlab variable names

if ~isfield(EEG, 'event')
    return
end
   
for i = 1:length(EEG.event)
    EEG.event(i).type(~isstrprop(EEG.event(i).type, 'alphanum')) = '';
    EEG.event(i).type = matlab.lang.makeValidName(lower(EEG.event(i).type));
end

end