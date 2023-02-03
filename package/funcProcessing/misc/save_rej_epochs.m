function save_rej_epochs(EEG)

[fpath, fname] = fileparts(fullfile(EEG.filepath, EEG.filename));
fname = fullfile(fpath, [fname, '_rejepochs.txt']);

event = table();

idx = (...
    regexpIdx({EEG.event.type}, 'reject') | ...
    regexpIdx({EEG.event.type}, 'Arousal') | ...
    regexpIdx({EEG.event.type}, 'Limb movement'));

event.onset    = ([EEG.event(idx).latency]' - 1) / EEG.srate;
event.duration = [EEG.event(idx).duration]' / EEG.srate;
event.type     = {EEG.event(idx).type}';

% Round onset and duration to the nearest millisecond
event.onset    = round(event.onset*1000)/1000;
event.duration = round(event.duration*1000)/1000;

% Write to file
writetable(event, fname)

end