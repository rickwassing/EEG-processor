function EEG = compumedics_import_data(FullFilePath)
% Create empty set
EEG = eeg_emptyset();
% Read header and data
HDR = ft_read_header(FullFilePath);
EEG.data = single(ft_read_data(FullFilePath));
% Set filename and path
[EEG.filepath, EEG.setname] = fileparts(FullFilePath);
EEG.filename = [EEG.setname, '.set'];
EEG.comments = sprintf('Original file: %s', FullFilePath);
% Set the recording dimensions
EEG.trials = HDR.nTrials;
EEG.pnts = HDR.nSamples;
EEG.srate = HDR.Fs;
EEG.times = 0:1/EEG.srate:(EEG.pnts-1)/EEG.srate;
EEG.xmin = EEG.times(1);
EEG.xmax = EEG.times(end);
% Set the reference type
EEG.ref = 'common';
% insert start date
EEG.etc.T0 = HDR.orig.T0;
EEG.etc.rec_startdate = datenum(EEG.etc.T0);
% Set the channel locations
EEG.chanlocs = struct('labels', '', 'ref', [], 'theta', [], 'radius', [], 'X', [], 'Y', [], 'Z', [], 'type', '', 'unit', '');
for i = 1:HDR.nChans
    EEG.chanlocs(i, 1).labels = HDR.label{i};
end
% Insert reference channel
EEG.chanlocs(end+1).labels = 'REF';
if ndims(EEG.data) == 3
    EEG.data(end+1, :, :) = zeros(1, EEG.pnts, EEG.trials, 'single');
else
    EEG.data(end+1, :) = zeros(1, EEG.pnts, 'single');
end
EEG.nbchan = size(EEG.data, 1);
% ************************************************************
% FOR TESTING PURPOSES ONLY PLEASE DELETE LATER
if EEG.nbchan == 3
    return
end
% ************************************************************
% The PIB channels are intermixed with the EEG channels, so we need
% to extract them and place them at the end of the rows
pibchans = false(1, EEG.nbchan);
pibchans([65:68, 133:136, 201:204, 269:272]) = true;
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
        EEG.chanlocs(i).ref = 'REF';
    end
    EEG.chanlocs(i).unit = '';
end

% Save original channel locations
EEG.urchanlocs = EEG.chanlocs;

% Rename the physiology channels
EEG.chanlocs = MapPnsWorkspace(EEG.chanlocs);


end