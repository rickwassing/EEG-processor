function [EEG, Warnings] = Proc_EpochSplit(EEG, SplitSettings, RejSettings, Warnings)

if SplitSettings.Do
    % Create temporary events, one for each split-block
    ntrials = floor(EEG.pnts / floor(SplitSettings.Interval * EEG.srate));
    fprintf('>> BIDS: Splitting dataset in %i epochs of %.3f seconds\n', ntrials, SplitSettings.Interval)
    for i = 1:ntrials
        EEG.event(end+1).latency = (i-1) * floor(SplitSettings.Interval * EEG.srate) + 1;
        EEG.event(end).duration = floor(SplitSettings.Interval * EEG.srate);
        EEG.event(end).type = 'splitblockevent';
        EEG.event(end).id = max([EEG.event.id])+1;
        EEG.event(end).is_reject = false;
    end
    % Epoch the dataset
    EEG = pop_epoch(EEG, {'splitblockevent'}, [0, SplitSettings.Interval]);
    % Rename splitblockevents to boundary
    IdxBoundaryEvents = find(strcmpi({EEG.event.type}, 'splitblockevent'));
    for i = 1:length(IdxBoundaryEvents)
        EEG.event(IdxBoundaryEvents(i)).type = 'boundary';
        EEG.event(IdxBoundaryEvents(i)).duration = 0;
    end
    % ---------------------------------------------------------
    % Remove epochs
    if RejSettings.Epochs
        % Get which epochs contain rejected time segments
        RejEpochs = [];
        if isfield(EEG.event, 'is_reject')
            for i = 1:length(EEG.event)
                if EEG.event(i).is_reject == 1
                    Onset = (EEG.event(i).latency/EEG.srate)/SplitSettings.Interval;
                    Offset = ((EEG.event(i).latency+EEG.event(i).duration)/EEG.srate)/SplitSettings.Interval;
                    RejEpochs = [RejEpochs, ceil(Onset):ceil(Offset)]; %#ok<AGROW>
                end
            end
        end
        RejEpochs(RejEpochs > EEG.trials) = [];
        % If not any reject event is found, trow a warning
        if isempty(RejEpochs)
            disp('>> BIDS: Did not remove any epochs, no rejected epochs found')
        else % ... continue with removing the rejected trials
            fprintf('>> BIDS: Removing %i rejected epochs\n', length(RejEpochs))
            EEG = pop_select(EEG, 'notrial', RejEpochs);
        end
    end
    % Update the JSON Struct
    EEG.etc.JSON.RecordingDuration = EEG.pnts/EEG.srate;
    EEG.etc.JSON.RecordingType = 'epoched';
    EEG.etc.JSON.TrialCount = EEG.trials;
end

end