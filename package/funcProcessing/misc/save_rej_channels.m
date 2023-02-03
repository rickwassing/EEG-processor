function save_rej_channels(EEG)

[fpath, fname] = fileparts(fullfile(EEG.filepath, EEG.filename));
fname = fullfile(fpath, [fname, '_rejchannels.txt']);
fid = fopen(fname, 'w');
if isfield(EEG.etc, 'rej_channels')
    fprintf(fid, '%s\n', EEG.etc.rej_channels{:});
else
    fprintf(fid, '\n');
end

fclose(fid);

end