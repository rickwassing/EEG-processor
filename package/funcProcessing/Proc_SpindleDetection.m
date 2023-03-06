function EEG = Proc_SpindleDetection(EEG, Settings)

fprintf('>> BIDS: Spindle detection using ''%s'' algorithm\n', Settings.Algorithm)
T = now;

switch lower(Settings.Algorithm)
    case 'lacourse'
        Settings = DefaultSpindleDetectionSettings(EEG, 'lacourse');
        Settings.Channels = {EEG.chanlocs(strcmpi({EEG.chanlocs.type}, 'EEG')).labels};
        SleepStageVec = repmat({'ns'}, EEG.pnts, 1);
        for i = 1:length(EEG.event)
            idx = round(EEG.event(i).latency):round(EEG.event(i).latency + EEG.event(i).duration - 1);
            switch EEG.event(i).type
                case {'wake', 'w'}
                    SleepStageVec(idx) = {'wake'};
                case {'nrem1', 'n1'}
                    SleepStageVec(idx) = {'nrem1'};
                case {'nrem2', 'n2'}
                    SleepStageVec(idx) = {'nrem2'};
                case {'nrem3', 'n3'}
                    SleepStageVec(idx) = {'nrem3'};
                case {'rem', 'r'}
                    SleepStageVec(idx) = {'rem'};
            end
        end
        for i = 1:length(Settings.Channels)
            ChanIdx = strcmpi({EEG.chanlocs.labels}, Settings.Channels{i});
            fprintf('>> BIDS: Running channel ''%s''\n', Settings.Channels{i})
            [~, ~, ~, spindles] = a7SpindleDetection(ascolumn(double(EEG.data(ChanIdx, :))), SleepStageVec, zeros(EEG.pnts, 1, 'single'), Settings);
            for j = 2:size(spindles, 1)
                EEG.event(end+1).type = lower(['spindle_', Settings.Channels{i}]);
                EEG.event(end).latency = spindles{j, 1};
                EEG.event(end).duration = spindles{j, 3};
                EEG.event(end).id = max([EEG.event.id])+1;
                EEG.event(end).is_reject = false;
            end
            EEG = eeg_checkset(EEG, 'eventconsistency');
        end

end

fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))

end