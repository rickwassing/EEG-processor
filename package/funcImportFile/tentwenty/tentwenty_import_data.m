function EEG = tentwenty_import_data(FullFilePath)

EEG = pop_biosig(FullFilePath);
EEG.event = [];
EEG.urevent = [];
% insert start date
EEG.etc.rec_startdate = datenum(EEG.etc.T0);
% Make sure the channel type is ok
pibchans = strcmpi({EEG.chanlocs.labels}, 'EOG');
EEG.chanlocs = [EEG.chanlocs(~pibchans); EEG.chanlocs(pibchans)];
if ndims(EEG.data) == 3
    EEG.data = [EEG.data(~pibchans, :, :); EEG.data(pibchans, :, :)];
else
    EEG.data = [EEG.data(~pibchans, :); EEG.data(pibchans, :)];
end
pibchans = sort(pibchans);
for i = 1:EEG.nbchan
    if pibchans(i)
        EEG.chanlocs(i).type = 'PNS';
    else
        EEG.chanlocs(i).type = 'EEG';
        switch EEG.chanlocs(i).labels(end)
            case {'1', '3'}
                EEG.chanlocs(i).ref = 'M2';
            case {'2', '4'}
                EEG.chanlocs(i).ref = 'M1';
            case 'z'
                EEG.chanlocs(i).ref = {'M1', 'M2'};
        end
    end
end
EEG.urchanlocs = EEG.chanlocs;

end