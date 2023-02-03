function EEG = Proc_AverageRef(EEG, Settings, RejChans)

if ~isempty(RejChans)
    fprintf('>> BIDS: Re-referencing EEG to average of all good EEG channels (%i rejected EEG channels)\n', sum(ismember({EEG.chanlocs.labels}, RejChans)))
    Exclude = find(...
        ismember({EEG.chanlocs.labels}, RejChans) | ...
        ~ismember({EEG.chanlocs.type}, 'EEG') ...
        );
else
    fprintf('>> BIDS: Re-referencing EEG to average of all EEG channels\n')
    Exclude = find(...
        ~ismember({EEG.chanlocs.type}, 'EEG') ...
        );
end
EEG = pop_reref(EEG, [], 'keepref', 'on', 'exclude', Exclude);
% -----
% Force all channels to have 'average' as their ref
for chan = 1:length(EEG.chanlocs)
    EEG.chanlocs(chan).ref = 'average';
end
% Update JSON struct
EEG.etc.JSON.EEGReference = EEG.ref;

end
