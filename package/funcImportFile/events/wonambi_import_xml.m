function [EEG, warnmsg] = wonambi_import_xml(EEG, xmlFile)

disp('>> BIDS: Importing events from Wonambi XML file')
warnmsg = [];

events = parseXML(xmlFile);

nRaters = 0;
for i = 1:length(events.Children)
    if strcmpi(events.Children(i).Name, 'rater')
        nRaters = nRaters + 1;
    end
end
% Run through all root children, and find "raters"
for i = 1:length(events.Children)
    if strcmpi(events.Children(i).Name, 'rater')
        rater = events.Children(i).Attributes(strcmpi({events.Children(i).Attributes.Name}, 'name')).Value;
        for j = 1:length(events.Children(i).Children)
            % The "rater" field contains...
            switch events.Children(i).Children(j).Name
                case 'bookmarks'
                    continue
                case 'events'
                    % Children within events have 'event_type' as children
                    for k = 1:length(events.Children(i).Children(j).Children)
                        if ~strcmpi(events.Children(i).Children(j).Children(k).Name, 'event_type')
                            continue
                        end
                        idx = strcmpi({events.Children(i).Children(j).Children(k).Attributes.Name}, 'type');
                        eventType = events.Children(i).Children(j).Children(k).Attributes(idx).Value;
                        % Extract event instances
                        for m = 1:length(events.Children(i).Children(j).Children(k).Children)
                            event = events.Children(i).Children(j).Children(k).Children(m);
                            onset = [];
                            offset = [];
                            chan = [];
                            for n = 1:length(event.Children)
                                switch event.Children(n).Name
                                    case 'event_start'
                                        onset = str2double(event.Children(n).Children.Data) .* EEG.srate + 1;
                                    case 'event_end'
                                        offset = str2double(event.Children(n).Children.Data) .* EEG.srate;
                                    case 'event_chan'
                                        chan = lower(regexprep(event.Children(n).Children.Data, '[^a-zA-Z0-9]', ''));
                                end
                            end
                            if isempty(onset) || isempty(offset) || isempty(chan)
                                continue
                            end
                            EEG.event(end+1).latency = onset;
                            EEG.event(end).duration = offset - onset;
                            if nRaters > 1
                                EEG.event(end).type = lower([eventType, '_', chan, '_', rater]);
                            else
                                EEG.event(end).type = lower([eventType, '_', chan]);
                            end
                        end
                    end
                case 'stages'
                    % Children within stages have 'epoch' as children
                    % Init stages variable
                    EEG.etc.stages = {};
                    % Extract event instances
                    for k = 1:length(events.Children(i).Children(j).Children)
                        event = events.Children(i).Children(j).Children(k);
                        if ~strcmpi(event.Name, 'epoch')
                            continue
                        end
                        onset = [];
                        offset = [];
                        stage = [];
                        for n = 1:length(event.Children)
                            switch event.Children(n).Name
                                case 'epoch_start'
                                    onset = str2double(event.Children(n).Children.Data) .* EEG.srate + 1;
                                case 'epoch_end'
                                    offset = str2double(event.Children(n).Children.Data) .* EEG.srate;
                                case 'stage'
                                    stage = lower(regexprep(event.Children(n).Children.Data, '[^a-zA-Z0-9]', ''));
                                    switch stage
                                        case 'wake'
                                            stage = 'Wake';
                                        case 'nrem1'
                                            stage = 'N1';
                                        case 'nrem2'
                                            stage = 'N2';
                                        case 'nrem3'
                                            stage = 'N3';
                                        case 'rem'
                                            stage = 'REM';
                                        otherwise
                                            stage = 'NS';
                                    end
                            end
                        end
                        if isempty(onset) || isempty(offset) || isempty(stage)
                            continue
                        end
                        EEG.event(end+1).latency = onset;
                        EEG.event(end).duration = offset - onset;
                        if nRaters > 1
                            EEG.event(end).type = [stage, '_', lower(rater)];
                        else
                            EEG.event(end).type = stage;
                        end
                        % Save stages in the cell array
                        EEG.etc.stages = [EEG.etc.stages, {stage}]; 
                    end
                otherwise
                    continue
            end
        end
    end
end

end
