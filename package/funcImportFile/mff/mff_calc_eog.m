function EEG = mff_calc_eog(EEG)

disp('>> BIDS: Calculating EOG signal')
T = now;

idxVEOG = [...
    find(strcmp({EEG.chanlocs.labels}, 'E18')), ...
    find(strcmp({EEG.chanlocs.labels}, 'E238'))
    ];
idxHEOG = [...
    find(strcmp({EEG.chanlocs.labels}, 'E1')), ...
    find(strcmp({EEG.chanlocs.labels}, 'E252'))
    ];
if length(idxVEOG) ~= 2 || length(idxHEOG) ~= 2
    error('Eye channels not found, please specify correct eye channels.')
end

% Add EOG channels to the dataset
EEG.data = [EEG.data; ...
    EEG.data(idxVEOG(1),:) - EEG.data(idxVEOG(2),:); ...
    EEG.data(idxHEOG(1),:) - EEG.data(idxHEOG(2),:)];
EEG.nbchan = EEG.nbchan+2;
EEG.chanlocs(end+1).labels = 'vEOG';
EEG.chanlocs(end).type     = 'VEOG';
EEG.chanlocs(end).unit     = 'uV';
EEG.chanlocs(end+1).labels = 'hEOG';
EEG.chanlocs(end).type     = 'HEOG';
EEG.chanlocs(end).unit     = 'uV';

fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))

end
