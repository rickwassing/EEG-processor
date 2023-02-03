function EEG = mff_newset(mffData)

EEG = eeg_emptyset;

[fpath, fname] = fileparts(mffData.meta_file);

% get meta info
EEG.comments = ['Original file: ' mffData.meta_file];
EEG.setname  = fname;
EEG.filename = fname;
EEG.filepath = fpath;

EEG.nbchan   = mffData.signal_binaries(1).num_channels;
EEG.srate    = mffData.signal_binaries(1).channels.sampling_rate(1);
EEG.trials   = length(mffData.epochs);
EEG.pnts     = mffData.signal_binaries(1).channels.num_samples(1);
EEG.xmin     = 0;
 
EEG.times    = 0:1/EEG.srate:(EEG.pnts-1)/EEG.srate;
EEG.xmax     = EEG.times(end);
% + ID #0003
idxDate = regexp(mffData.meta_file, '[0-9]{8}_[0-9]{6}');
if ~isempty(idxDate)
    EEG.etc.rec_startdate = datestr(datenum(mffData.meta_file(idxDate:idxDate+14), 'yyyymmdd_HHMMSS'), 'yyyy-mm-ddTHH:MM:SS');
    EEG.etc.T0 = datevec(datenum(EEG.etc.rec_startdate, 'yyyy-mm-ddTHH:MM:SS'));
end