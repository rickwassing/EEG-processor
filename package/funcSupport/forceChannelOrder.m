function EEG = forceChannelOrder(EEG)

eegChans = find(strcmp({EEG.chanlocs.type}, 'EEG'));
pnsChans = find(~strcmp({EEG.chanlocs.type}, 'EEG'));
EEG.chanlocs = [asrow(EEG.chanlocs(eegChans)), asrow(EEG.chanlocs(pnsChans))];
EEG.data = [EEG.data(eegChans, :, :); EEG.data(pnsChans, :, :)];
end