function [EEG, warnmsg] = compumed_import_sleep_events(EEG, eventFile, mffName)

disp('>> BIDS: Importing events from Scored Events file')
warnmsg = [];

if nargin < 3
    if ~isfield(EEG, 'etc')
        error('Dataset does not contain recording start date and time');
    elseif ~isfield(EEG.etc, 'rec_startdate')
        error('Dataset does not contain recording start date and time');
    end
else
    idxDate = regexp(mffName, '[0-9]{8}_[0-9]{6}');
    EEG.etc.rec_startdate = datenum(mffName(idxDate:idxDate+14), 'yyyymmdd_HHMMSS');
end

% + #0002
if ischar(EEG.etc.rec_startdate)
    EEG.etc.rec_startdate = datenum(EEG.etc.rec_startdate, 'yyyy-mm-ddTHH:MM:SS');
end

% Remove any sleep events that are currently in the events
if isstruct(EEG.event)
    if ~isempty(EEG.event) && isfield(EEG.event, 'type')
        idx = regexpIdx({EEG.event.type}, 'Arousal|Apnea|Hypopnea|Limb|Snore|SpO2|RERA');
        if any(idx)
            warnmsg = 'Scored Events have been overwritten.';
            EEG.event(idx) = [];
        end
    end
end

% Check the file is not empty
fid = fopen(eventFile);
if all(fgetl(fid) == -1)
  % file is empty
  fclose(fid);
  warnmsg = 'No Scored Events loaded, file is empty.';
  return
else
    fclose(fid);
end

% get sleep events
opts   = detectImportOptions(eventFile, ...
    'FileType', 'delimitedtext', ...
    'TextType', 'char', ...
    'DatetimeType', 'text', ...
    'NumHeaderLines', 0, ...
    'ReadVariableNames', false, ...
    'Delimiter', ',');
if length(opts.VariableNames) == 4
    opts   = setvartype(opts, {'char', 'double', 'char', 'char'});
    events = readtable(eventFile, opts, 'ReadVariableNames', false);
    events.Properties.VariableNames = [{'Onset'},{'Epoch'},{'Stage'},{'Type'}];
    events.Duration = repmat({'00:00.500'}, size(events, 1), 1);
else
    opts   = setvartype(opts, {'char', 'double', 'char', 'char', 'char', 'char', 'char', 'char'});
    events = readtable(eventFile, opts, 'ReadVariableNames', false);
    events.Properties.VariableNames = [{'Onset'},{'Epoch'},{'Stage'},{'Type'},{'Duration'},{'Meta1'},{'Meta2'},{'x'}];
end
% calculate the relative time since beginning of the recording
% add = 0; - #0001
for e = 1:size(events, 1)
    add = 0; % + #0001
    dstr = [datestr(EEG.etc.rec_startdate+add, 'yyyy-mm-dd') 'T' events.Onset{e}];
    while datenum(dstr, 'yyyy-mm-ddTHH:MM:SS') - EEG.etc.rec_startdate < 0
        add = add+1;
        dstr = [datestr(EEG.etc.rec_startdate+add, 'yyyy-mm-dd') 'T' events.Onset{e}];
    end
    EEG.event(end+1).latency = (datenum(dstr, 'yyyy-mm-ddTHH:MM:SS') - EEG.etc.rec_startdate) * 24*60*60*EEG.srate + 1;
    if isempty(regexp(events.Duration{e}, '\.', 'once'))
        EEG.event(end).duration = datenum(['0000-01-00T00:' events.Duration{e}], 'yyyy-mm-ddTHH:MM:SS') * 24*60*60*EEG.srate;
    else
        EEG.event(end).duration = datenum(['0000-01-00T00:' events.Duration{e}], 'yyyy-mm-ddTHH:MM:SS.FFF') * 24*60*60*EEG.srate;
    end
    type = events.Type{e};
    type(~isstrprop(type, 'alphanum')) = '';
    type = lower(matlab.lang.makeValidName(type));
    EEG.event(end).type = type;
end
EEG.etc.rec_startdate = datestr(EEG.etc.rec_startdate, 'yyyy-mm-ddTHH:MM:SS');