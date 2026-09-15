function EEG = grael_import_data(FullFilePath)
% Read header and data
hdr = ft_read_header(FullFilePath);
% ID #0020
data = edf2fieldtrip(FullFilePath);

% OLD CODE
% % % % List the labels of expected EEG channels, they do not all have to be in
% % % % the recording, but at least one of these, and the labels must conform to
% % % % these nomenclatures
% % % ExpEEGChanLabels = {'Fpz', 'Fz', 'F3', 'F4', 'Cz', 'C3', 'C4', 'Pz', 'Oz', 'O1', 'O2', 'M1', 'M2'};
% % % % Logical index of all EEG channels
% % % eegChans = find(ismember(data.label, ExpEEGChanLabels));

ExpEEGChanLabels = {'Fpz', 'Fz', 'F3', 'F4', 'Cz', 'C3', 'C4', 'Pz', 'Oz', 'O1', 'O2', 'M1', 'M2'};
% Parse the EEG channel labels and their references
[data.label, references, eegChans] = parseRoutineChanLabel(data.label);
pnsChans = find(~eegChans);
eegChans = find(eegChans);

% If not any EEG channels found, throw error
if isempty(eegChans)
    error('No EEG channels found with any of the following labels: ''Fpz'', ''Fz'', ''F3'', ''F4'', ''Cz'', ''C3'', ''C4'', ''Pz'', ''Oz'', ''O1'', ''O2'', ''M1'', ''M2''.')
end
% Sort the channels
idx = nan(size(eegChans));
for i = 1:length(eegChans)
    idx(i) = find(strcmpi(ExpEEGChanLabels, data.label{eegChans(i)}));
end
[~, idx] = sort(idx);
eegChans = eegChans(idx);
% Create new empty EEG struct
EEG = eeg_emptyset();
% The data must be referenced to a common ref electrode (i.e., no other montage allowed)
EEG.ref = 'common';
EEG.comments = sprintf('Original file: %s', FullFilePath);
EEG.nbchan = length(eegChans);
EEG.trials = 1;
EEG.pnts = size(data.trial{1}, 2);
EEG.srate = data.fsample;
EEG.xmin = 0;
EEG.xmax = (EEG.pnts-1)/EEG.srate;
EEG.times = EEG.xmin:1/EEG.srate:EEG.xmax;
EEG.etc.T0 = hdr.orig.T0;
EEG.etc.rec_startdate = datestr(EEG.etc.T0, 'yyyy-mm-ddTHH:MM:SS'); %#ok<DATST>
% Extract the EEG data
for i = 1:length(eegChans)
    % Extract and vectorize the data
    EEG.data(i, :) = data.trial{1}(eegChans(i), :);
end
% Set the channel locations
EEG.chanlocs = struct('labels', '', 'X', [], 'Y', [], 'Z', [], 'theta', [], 'radius', [], 'ref', '', 'type', '', 'unit', '');
for i = 1:EEG.nbchan
    EEG.chanlocs(i, 1).labels = data.label{eegChans(i)};
    EEG.chanlocs(i, 1).unit = deblank(hdr.orig.PhysDim(eegChans(i), :));
    EEG.chanlocs(i).type = 'EEG';
    EEG.chanlocs(i).ref = references{eegChans(i)};
end
% if all references are common, then save this in EEG.ref
if all(strcmpi({EEG.chanlocs.ref}, 'common'))
    EEG.ref = 'common';
else
    EEG.ref = 'mixed';
end
% Now import all Phys channels
for i = 1:length(pnsChans)
    % Extract and vectorize the data
    EEG.data(end+1, :) = data.trial{1}(pnsChans(i), :);
    EEG.chanlocs(end+1, 1).labels = data.label{pnsChans(i)};
    EEG.chanlocs(end, 1).unit = deblank(hdr.orig.PhysDim(pnsChans(i), :));
    EEG.chanlocs(end).type = 'MISC';
end

% Rename the physiology channels
EEG.chanlocs = MapPnsWorkspace(EEG.chanlocs);

% Sort by type
idx = [...
    find(strcmpi({EEG.chanlocs.type}, 'EEG')), ...
    find(strcmpi({EEG.chanlocs.type}, 'EOG')), ...
    find(strcmpi({EEG.chanlocs.type}, 'ECG')), ...
    find(strcmpi({EEG.chanlocs.type}, 'EMG')), ...
    find(strcmpi({EEG.chanlocs.type}, 'Respiratory')), ...
    find(strcmpi({EEG.chanlocs.type}, 'NasalPressure')), ...
    find(strcmpi({EEG.chanlocs.type}, 'Snoring'))];
idx = [idx, setdiff(1:length(EEG.chanlocs), idx)];
EEG.data = EEG.data(idx, :);
EEG.chanlocs = EEG.chanlocs(idx);

% Save original channel locations
EEG.urchanlocs = EEG.chanlocs;


end