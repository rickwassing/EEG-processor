function EEG = Import_SelectTenTwentyChans(EEG, DataType)

disp('>> BIDS: Cropping high-density EEG channels to 10-20 electrodes')
% Find indices of the 10-20 EEG channels, plus Cz.
switch DataType
    case 'MFF'
        Chans = {'Cz', 'E1', 'E18', 'E21', 'E36', 'E59', 'E87', 'E94', 'E101', 'E116', 'E126', 'E150', 'E153', 'E183', 'E190', 'E224', 'E238', 'E252'};
    case 'COMPU257'
        Chans = {'Fp1', 'Fpz', 'Fp2', 'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4', 'O1', 'Oz', 'O2', 'M1', 'M2', 'REF'};
    case 'TENTWENTY'
        return % Is already a Ten Twenty recording
    otherwise
        error('Cannot select 10-20 channels for this data type ''%s''', DataType)
end
idx = ismember({EEG.chanlocs.labels}, Chans);
% Throw an error if not all specified EEG channels could be found
if sum(idx) ~= length(Chans)
    error('%s: Could not find all specified EEG channels in the data.', EEG.filename)
end
% Reduce EEG.chanlocs and update the number of channels
EEG.chanlocs = EEG.chanlocs(idx);
EEG.nbchan = length(EEG.chanlocs);

end