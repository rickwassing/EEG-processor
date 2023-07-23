function [EEG, warnmsg] = compumed_import_sleep_scores(EEG, scoreFile)

disp('>> BIDS: Importing events from Hypnogram file')
warnmsg = [];

% Check if Hypnogram events exist already, if so, overwrite them
if isstruct(EEG.event)
    if isfield(EEG.event, 'type')
        idx = ismember(lower({EEG.event.type}), {'1', '2', '3', 'n1', 'n2', 'n3', 's1', 's2', 's3', 'nrem1', 'nrem2', 'nrem3', 'r', 'rem', 'w', 'wake', 'ns'});
        if any(idx)
            warnmsg = 'Hypnogram events have been overwritten';
            EEG.event(idx) = [];
        end
    end
end
            
% get the hypnogram
stages = readtable(scoreFile, 'ReadVariableNames', false, 'Format', '%s');
EEG.etc.stages = stages.Var1;
for s = 1:size(stages, 1)
    EEG.event(end+1).latency  = (s-1)*30*EEG.srate + 1;
    EEG.event(end).duration   = 30*EEG.srate;
    switch stages.Var1{s}
        case '1'
            EEG.event(end).type = 'N1';
        case '2'
            EEG.event(end).type = 'N2';
        case '3'
            EEG.event(end).type = 'N3';
        case 'R'
            EEG.event(end).type = 'REM';
        case 'W'
            EEG.event(end).type = 'Wake';
        otherwise
            EEG.event(end).type = 'NS';
    end
end

EEG = forceValidEventType(EEG);

end
