function [EEG, EventSelSettings, Warnings] = Proc_EpochEventSel(EEG, EventSelSettings, RejSettings, TimeSelSettings, Warnings)
% -----
% First, make sure we are doing epoching by events
if ~EventSelSettings.Do
    return
end
% -----
% make sure there is an 'id' value for each event
for i = 1:length(EEG.event)
    EEG.event(i).id = i;
end
% -----
% If the user requested to create separate files for each event instance,
% then we relabel each event appended with an integer value
EventSelLabels = cell(0);
if EventSelSettings.SeparateFilesPerInstance
    for i = 1:length(EventSelSettings.Labels)
        selEvents = EEG.event(ismember({EEG.event.type}, EventSelSettings.Labels{i}));
        for j = 1:length(selEvents)
            SelIdx = [EEG.event.id] == selEvents(j).id;
            EEG.event(SelIdx).type = [EEG.event(SelIdx).type, num2str(j)];
            EventSelLabels = [EventSelLabels, {EEG.event(SelIdx).type}];
        end
    end
    EventSelSettings.Labels = EventSelLabels;
end
% -----
% Copy the original events over
EEG.urevent = EEG.event;
% -----
% Run epoching using an epoch around the event
% - or - epoch using the event onset and duration
if EventSelSettings.UseEpochTime
    % -----
    % Adjust the event timing relative to requested "onset", "center" or "offset"
    EEG = AdjustEventTiming(EEG, EventSelSettings);
    % -----
    % Get which events contain rejected time segments
    if isfield(EEG.event, 'is_reject')
        RejEventIdx = [EEG.event.is_reject] == 1;
        if any(RejEventIdx)
            RejEpochs = [ascolumn([EEG.event(RejEventIdx).latency]), ascolumn([EEG.event(RejEventIdx).latency] + [EEG.event(RejEventIdx).duration])];
            EventSelIdx = find(ismember({EEG.event.type}, EventSelSettings.Labels));
            for i = 1:length(EventSelIdx)
                Onset = EEG.event(EventSelIdx(i)).latency + (EventSelSettings.Interval(1)*EEG.srate);
                Offset = EEG.event(EventSelIdx(i)).latency + (EventSelSettings.Interval(2)*EEG.srate);
                % Check if this event covers a rejected time segment
                if any(...
                        (Onset <= RejEpochs(:, 1) & Offset >= RejEpochs(:, 1)) | ...
                        (Onset >= RejEpochs(:, 1) & Offset <= RejEpochs(:, 2)) | ...
                        (Onset <= RejEpochs(:, 2) & Offset >= RejEpochs(:, 2)))
                    EEG.event(EventSelIdx(i)).is_reject = true;
                end
            end
        end
    end
    % -----
    % Epoch the dataset
    if EventSelSettings.SeparateFiles
        for i = 1:length(EventSelSettings.Labels)
            fprintf('>> BIDS: Creating separate epoched dataset for the event ''%s''\n', EventSelSettings.Labels{i})
            fprintf('>> BIDS: in %i epochs using %.3f seconds pre-stim and %.3f seconds post-stim\n', sum(strcmpi({EEG.event.type}, EventSelSettings.Labels{i})), EventSelSettings.Interval(1), EventSelSettings.Interval(2))
            tmpeeg(i) = SelectDataUsingEventLabels(EEG, EventSelSettings.Labels(i), EventSelSettings.Interval); %#ok<*AGROW>
        end
        EEG = tmpeeg; clear tmpeeg;
    else
        fprintf('>> BIDS: Creating a single epoched dataset for the events ''%s''\n', strjoin(EventSelSettings.Labels, ''', '''));
        fprintf('>> BIDS: in %i epochs using %.3f seconds pre-stim and %.3f seconds post-stim\n', sum(ismember({EEG.event.type}, EventSelSettings.Labels)), EventSelSettings.Interval(1), EventSelSettings.Interval(2))
        EEG = SelectDataUsingEventLabels(EEG, EventSelSettings.Labels, EventSelSettings.Interval);
    end
    % ---------------------------------------------------------
    % Make sure there is an epoch field in the event structure
    for i = 1:length(EEG)
        if ~isfield(EEG(i).event, 'epoch') && EEG(i).trials == 1
            for j = 1:length(EEG(i).event)
                EEG(i).event(j).epoch = 1;
            end
        elseif ~isfield(EEG(i).event, 'epoch')
            error('An unexpected error occurred after epoching the dataset')
        end
    end
    % ---------------------------------------------------------
    % Remove rejected epochs
    if RejSettings.Epochs
        for i = 1:length(EEG)
            if isfield(EEG(i).event, 'is_reject')
                % Get which epochs contain rejected time segments
                RejEpochs = unique([EEG(i).event([EEG(i).event.is_reject] == 1).epoch]);
                % If not any reject event is found, trow a warning
                if isempty(RejEpochs)
                    fprintf('>> BIDS: Did not remove any epochs, no rejected epochs found in dataset %i of %i\n', i, length(EEG))
                else % ... continue with removing the rejected trials
                    if length(RejEpochs) == EEG(i).trials
                        % Then all trials need to be removed. If we'd use
                        % 'pop_select' this will result in an error so we
                        % have to manually generate an empty set
                        fprintf('>> BIDS: All epochs contained a reject event and were removed. No data remaining in dataset %i of %i\n', i, length(EEG))
                        Warnings = [Warnings; {sprintf('All epochs contained a reject event and were removed. No data remaining in dataset %i of %i\n', i, length(EEG))}];
                        Warnings = [Warnings; {'-----'}];
                        EEG(i).data = zeros(EEG(i).nbchan, 1);
                        EEG(i).pnts = 1;
                        EEG(i).trials = 1;
                        EEG(i).xmin = 0;
                        EEG(i).xmax = 1/EEG(i).srate;
                        EEG(i).times = 0;
                        EEG(i).event(:) = [];
                    else
                        fprintf('>> BIDS: Removing %i rejected epochs in dataset %i of %i\n', length(RejEpochs), i, length(EEG))
                        EEG(i) = pop_select(EEG(i), 'notrial', RejEpochs);
                    end
                end
            else
                fprintf('>> BIDS: Did not remove any epochs, no rejected epochs identified in dataset %i of %i\n', i, length(EEG))
            end
        end
    end
    % For each EEG dataset...
    for i = 1:length(EEG)
        % ... insert boundary events
        if EEG(i).trials > 1
            for j = 1:EEG(i).trials
                % Insert boundary event
                EEG(i).event(end+1).latency = j*range(EventSelSettings.Interval)*EEG(i).srate;
                EEG(i).event(end).duration = 0;
                EEG(i).event(end).type = 'boundary';
                EEG(i).event(end).id = max([EEG(i).event.id])+1;
                EEG(i).event(end).is_reject = false;
                EEG(i).event(end).epoch = j;
            end
            [~, SortIdx] = sort([EEG(i).event.latency]);
            EEG(i).event = EEG(i).event(SortIdx);
        end
        % ... update the JSON Struct
        EEG(i).etc.JSON.RecordingDuration = EEG.pnts/EEG.srate;
        EEG(i).etc.JSON.RecordingType = 'epoched';
        EEG(i).etc.JSON.TrialCount = EEG.trials;
    end
else % Use the event onset and duration
    % Index to select time
    if ~TimeSelSettings.AllFile
        % Fixed ID #0009
        TimeSelIdx = EEG.times >= TimeSelSettings.Interval(1) & EEG.times <= TimeSelSettings.Interval(2);
    else
        TimeSelIdx = true(1, EEG.pnts);
    end
    % ---------------------------------------------------------
    % Index to remove rejected epochs later
    if RejSettings.Epochs
        RejIdx = eegevent2idx(EEG.event([EEG.event.is_reject] == 1), 1:EEG.pnts);
    else
        RejIdx = false(1, EEG.pnts);
    end
    % -----
    % Epoch the dataset
    if EventSelSettings.SeparateFiles
        for i = 1:length(EventSelSettings.Labels)
            fprintf('>> BIDS: Creating separate discontinuous dataset spanning the occurances of the event ''%s''\n', EventSelSettings.Labels{i})
            selEvents = EEG.event(ismember({EEG.event.type}, EventSelSettings.Labels{i}));
            if EventSelSettings.EnforceDuration
                for j = 1:length(selEvents)
                    selEvents(j).duration = EEG.srate * EventSelSettings.EnforceDurationWindow;
                end
            end
            SelIdx = eegevent2idx(selEvents, 1:EEG.pnts);
            if ~any(SelIdx & TimeSelIdx & ~RejIdx)
                Warnings = [Warnings; {sprintf('Could not select dataset for event ''%s''. No valid data points.', EventSelSettings.Labels{i})}];
                Warnings = [Warnings; {'-----'}];
                tmpeeg(i) = EEG;
                tmpeeg(i).data = zeros(EEG.nbchan, 1);
                tmpeeg(i).pnts = 1;
                tmpeeg(i).trials = 1;
                tmpeeg(i).xmin = 0;
                tmpeeg(i).xmax = 1/EEG.srate;
                tmpeeg(i).times = 0;
                tmpeeg(i).event(:) = [];
                continue
            end
            if RejSettings.Epochs
                fprintf('>> BIDS: Removing %.3f s of rejected epochs in dataset %i of %i\n', sum(SelIdx & TimeSelIdx & RejIdx)/EEG.srate, i, length(EventSelSettings.Labels))
            end
            [PointOnset, PointDuration] = idx2bouts(SelIdx & TimeSelIdx & ~RejIdx);
            tmpeeg(i) = SelectDataUsingOnsetDuration(EEG, 'point', PointOnset, PointDuration);
            % make sure there is an 'id' and 'is_reject' value for each event
            for j = 1:length(tmpeeg(i).event)
                tmpeeg(i).event(j).id = j;
                if isempty(tmpeeg(i).event(j).is_reject)
                    tmpeeg(i).event(j).is_reject = 0;
                end
            end
            % if reject epochs have been removed, then also remove the reject events
            if RejSettings.Epochs
                if ~isempty(tmpeeg(i).event)
                    tmpeeg(i).event([tmpeeg(i).event.is_reject] == 1) = [];
                end
            end
        end
        EEG = tmpeeg; clear tmpeeg;
    else
        fprintf('>> BIDS: Creating a single discontinuous dataset spanning the occurances of the events ''%s''\n', strjoin(EventSelSettings.Labels, ''', '''));
        selEvents = EEG.event(ismember({EEG.event.type}, EventSelSettings.Labels));
        if EventSelSettings.EnforceDuration
            for j = 1:length(selEvents)
                selEvents(j).duration = EEG.srate * EventSelSettings.EnforceDurationWindow;
            end
        end
        SelIdx = eegevent2idx(selEvents, 1:EEG.pnts);
        fprintf('>> BIDS: Removing %.3f s of rejected epochs\n', sum(SelIdx & TimeSelIdx & RejIdx)/EEG.srate)
        if ~any(SelIdx & TimeSelIdx & ~RejIdx)
            Warnings = [Warnings; {sprintf('Could not select dataset for events %s. No valid data points.', strjoin(EventSelSettings.Labels, ''', '''))}];
            Warnings = [Warnings; {'-----'}];
            EEG = rmfield(EEG, 'data');
            EEG.data = zeros(EEG.nbchan, 1);
            EEG.pnts = 1;
            EEG.xmin = 0;
            EEG.xmax = 1/EEG.srate;
            EEG.times = 0;
            EEG.event(:) = [];
            return
        end
        [PointOnset, PointDuration] = idx2bouts(SelIdx & TimeSelIdx & ~RejIdx);
        EEG = SelectDataUsingOnsetDuration(EEG, 'point', PointOnset, PointDuration);
    end
    % Update the JSON Struct
    for i = 1:length(EEG)
        EEG(i).etc.JSON.RecordingDuration = EEG(i).pnts/EEG(i).srate;
        EEG(i).etc.JSON.RecordingType = 'discontinuous';
        EEG(i).etc.JSON.TrialCount = EEG(i).trials;
    end
end

    % ---------------------------------------------------------------------
    % Adjust event timing to "onset", "center" or "offset"
    function eeg = AdjustEventTiming(eeg, settings)
        switch settings.RelativeTo
            case 'onset'
                % Do nothing
            case 'center'
                % Adjust the onset of the events to (onset + 0.5*duration)
                disp('>> BIDS: Adjusting event latencies to the center of each selected event')
                for k = 1:length(eeg.urevent)
                    if ismember(eeg.urevent(k).type, settings.Labels)
                        eeg.event(k).latency = eeg.event(k).latency + eeg.event(k).duration/2;
                        eeg.event(k).duration = eeg.event(k).duration/2;
                    end
                end
            case 'offset'
                % Adjust the onset of the events to the offset
                disp('>> BIDS: Adjusting event latencies to the offset of each selected event')
                for k = 1:length(eeg.urevent)
                    if ismember(eeg.urevent(k).type, settings.Labels)
                        eeg.event(k).latency = eeg.event(k).latency + eeg.event(k).duration;
                        eeg.event(k).duration = 0;
                    end
                end
        end
    end

end