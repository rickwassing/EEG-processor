function EEG = grael_import_data(FullFilePath)

% Read file
% [EEG, ~, HDR] = pop_biosig(FullFilePath, 'importevent', 'off', 'importannot', 'off');
% Read header and data
hdr = ft_read_header(FullFilePath);
[data, annot] = edfread(FullFilePath); % annotations are not yet implemented, maybe a later version?
% List the labels of expected EEG channels, they do not all have to be in
% the recording, but at least one of these, and the labels must conform to
% these nomenclatures
ExpEEGChanLabels = {'Fpz', 'Fz', 'F3', 'F4', 'Cz', 'C3', 'C4', 'Pz', 'Oz', 'O1', 'O2', 'M1', 'M2'};
% Logical index of all EEG channels
eegChans = ismember(data.Properties.VariableNames, ExpEEGChanLabels);
% If not any EEG channels found, throw error
if ~any(eegChans)
    error('No EEG channels found with any of the following labels: ''Fpz'', ''Fz'', ''F3'', ''F4'', ''Cz'', ''C3'', ''C4'', ''Pz'', ''Oz'', ''O1'', ''O2'', ''M1'', ''M2''.')
end
% Create new empty EEG struct
EEG = eeg_emptyset();
% The data must be referenced to a common ref electrode (i.e., no other montage allowed)
EEG.ref = 'common';
EEG.comments = sprintf('Original file: %s', FullFilePath);
EEG.trials = 1;
EEG.nbchan = size(data, 2);
EEG.pnts = sum(cellfun(@(ts) length(ts), data.(data.Properties.VariableNames{find(eegChans, 1)})));
EEG.srate = hdr.Fs;
EEG.xmin = 0;
EEG.xmax = (EEG.pnts-1)/EEG.srate;
EEG.times = EEG.xmin:1/EEG.srate:EEG.xmax;
EEG.etc.T0 = hdr.orig.T0;
EEG.etc.rec_startdate = datestr(EEG.etc.T0, 'yyyy-mm-ddTHH:MM:SS');
% Extract the data and resample as necessary
for i = 1:size(data, 2)
    % Extract and vectorize the data
    ts = data{:, i};
    ts = [ts{:}];
    ts = reshape(ts, 1, numel(ts));
    % Check if we need to resample it
    if length(ts) ~= EEG.pnts
        [p,q] = rat(EEG.srate/hdr.orig.SampleRate(i), 1e-12);
        fc = 0.9; % normalized anti-aliasing filter cutoff
        df = 0.2; % normalized anti-aliasing filter transition bandwidth
        usesigproc = 1;
        ts = eegproc_resample(ascolumn(ts), p, q, usesigproc, fc, df);
    end
    EEG.data(i, :) = ts;
end
% Set the channel locations
EEG.chanlocs = struct('labels', '', 'X', [], 'Y', [], 'Z', [], 'theta', [], 'radius', [], 'ref', '', 'type', '', 'unit', '');
for i = 1:EEG.nbchan
    EEG.chanlocs(i, 1).labels = data.Properties.VariableNames{i};
    EEG.chanlocs(i, 1).unit = deblank(hdr.orig.PhysDim(i, :));
    if eegChans(i)
        EEG.chanlocs(i).type = 'EEG';
        EEG.chanlocs(i).ref = 'common';
    else
        EEG.chanlocs(i).type = 'PNS';
    end
end
% Re-order the channels so that the EEG channels appear first then the PNS chans
EEG = forceChannelOrder(EEG);

% Sort EEG channels
[~, resort] = sort(arrayfun(@(c) ...
    ifelse(isempty(find(strcmpi(c.labels, ExpEEGChanLabels), 1)), ...
        NaN, ...
        find(strcmpi(c.labels, ExpEEGChanLabels))), ...
    EEG.chanlocs));
EEG.chanlocs = EEG.chanlocs(resort);
EEG.data = EEG.data(resort, :);

% Save original channel locations
EEG.urchanlocs = EEG.chanlocs;

% Rename the physiology channels
EEG.chanlocs = MapPnsWorkspace(EEG.chanlocs);

end