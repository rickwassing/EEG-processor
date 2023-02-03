function EEG = SelectDataUsingOnsetDuration(EEG, type, onset, duration)

% Select 
EEG = pop_select(EEG, type, [onset, onset+duration]);
% Calculate how much time should be added to the recording start date
switch type
    case 'point' % in samples
        addays = onset(1)/(24*60*60*EEG.srate);
    case 'time' % in seconds
        addays = onset(1)/(24*60*60);
end
EEG.etc = updateRecStartDate(EEG.etc, addays);

end