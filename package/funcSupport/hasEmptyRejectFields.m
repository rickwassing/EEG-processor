function bool = hasEmptyRejectFields(EEG)
bool = false;
for i = 1:length(EEG.event)
    if isempty(EEG.event(i).is_reject)
        bool = true;
        return
    end
end
end