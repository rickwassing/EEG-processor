function EEG = mff_import_piblocs(EEG, mffName)

pnsSetFile = fullfile(mffName, 'pnsSet.xml');
pnsSets = pns_workspaces();

% Check if file exists
if exist(pnsSetFile, 'file') == 0
    warning('Could not find ''pnsSet.xml'' in the MFF package')
    return
end

% Try to parse the XML file, otherwise throw an error
try
    pnsSetXML = parseXML(pnsSetFile);
catch ME
    error(['Could not parse ''pnsSet.xml''. ', ME.message])
end

% Find the index of the 'sensors' field
idx = strcmpi({pnsSetXML.Children.Name}, 'sensors');
if ~any(idx)
    error('Did not find sensors in the ''pnsSet.xml'' file')
end
sensors = pnsSetXML.Children(idx).Children;

% Find the index of the 'sensor' fields
idx = strcmpi({sensors.Name}, 'sensor');
if ~any(idx)
    error('Did not find single sensor information in the ''pnsSet.xml'' file')
end

sensors = sensors(idx);
for si = 1:length(sensors)
    % Find the 'name' field
    idx = strcmpi({sensors(si).Children.Name}, 'name');
    if ~any(idx)
        error('Did not find the single sensor name in the ''pnsSet.xml'' file')
    end
    % Transfer the channel labels to the main EEG struct
    EEG.chanlocs(end+1).labels = sensors(si).Children(idx).Children.Data;
    idxLabel = strcmpi(EEG.chanlocs(end).labels, {pnsSets.labels});
    if ~any(idxLabel)
        EEG.chanlocs(end).type = 'OTHER';
    else
        EEG.chanlocs(end).type = pnsSets(strcmpi(EEG.chanlocs(end).labels, {pnsSets.labels})).type;
    end
    % Find the 'unit' field
    idx = strcmpi({sensors(si).Children.Name}, 'unit');
    if any(idx)
        if ~isempty(sensors(si).Children(idx).Children)
            EEG.chanlocs(end).unit = sensors(si).Children(idx).Children.Data;
        else
            EEG.chanlocs(end).unit = 'unknown';
        end
    else
        EEG.chanlocs(end).unit = 'unknown';
    end
end
% Rename the physiology channels
EEG.chanlocs = MapPnsWorkspace(EEG.chanlocs);
end
