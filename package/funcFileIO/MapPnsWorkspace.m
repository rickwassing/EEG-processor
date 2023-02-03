function chanlocs = MapPnsWorkspace(chanlocs)

% Rename the physiology channels
pnsSets = pns_workspaces();
for i = 1:length(chanlocs)
    if strcmpi(chanlocs(i).type, 'EEG')
        continue
    end
    idxLabel = strcmpi({pnsSets.labels}, chanlocs(i).labels);
    if ~any(idxLabel)
        continue
    else
        chanlocs(i).labels = pnsSets(idxLabel).relabel;
        chanlocs(i).type = pnsSets(idxLabel).type;
    end
end
% Make sure all channels labels are valid Matlab Var names
for i = 1:length(chanlocs)
    chanlocs(i).labels = matlab.lang.makeValidName(chanlocs(i).labels);
end


end