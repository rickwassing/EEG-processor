function EEG = SelectDataUsingEventLabels(EEG, labels, interval)

% Update the rec-start date, find latency of the first instance of the event
idx = find(ismember({EEG.event.type}, labels), 1, 'first');
EEG.etc = updateRecStartDate(EEG.etc, ((EEG.event(idx).latency/EEG.srate) + interval(1))/(24*60*60));

% Select 
EEG = pop_epoch(EEG, labels, interval);

end