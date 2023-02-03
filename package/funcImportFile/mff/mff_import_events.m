function EEG = mff_import_events(EEG, mffName)

% Check if files exists
if exist(fullfile(mffName, 'info.xml'), 'file') == 0
    error('Could not find ''info.xml'' in the MFF package')
end
if exist(fullfile(mffName, 'epochs.xml'), 'file') == 0
    warning('Could not find ''epochs.xml'' in the MFF package. Assuming one continuous recording.')
    epochxml = struct([]);
else
    epochxml = parseXML(fullfile(mffName, 'epochs.xml'));
end
if exist(fullfile(mffName, 'Events_User Markup.xml'), 'file') == 0
    error('Could not find ''Events_User Markup.xml'' in the MFF package')
end

infoxml = parseXML(fullfile(mffName, 'info.xml'));

for f = 1:size(infoxml.Children,2)
    switch infoxml.Children(f).Name
        case 'recordTime'
            EEG.etc.amp_startdate = infoxml.Children(f).Children.Data;
    end
end

% Epoch structure indicates the onset and offset of epochs in microseconds
% since the start of the recording
epoch = struct();
epoch(1).onsetMicroSec = 0;
epoch(1).offsetMicroSec = round((EEG.times(end)+1/EEG.srate)*1000000);
epoch(1).delay = 0;
if ~isempty(epochxml)
    cnt = 0;
    for f = 1:length(epochxml.Children)
        switch epochxml.Children(f).Name
            case 'epoch'
                cnt = cnt+1;
                for c = 1:length(epochxml.Children(f).Children)
                    switch epochxml.Children(f).Children(c).Name
                        case 'beginTime'
                            epoch(cnt).onsetMicroSec = str2double(epochxml.Children(f).Children(c).Children.Data);
                        case 'endTime'
                            epoch(cnt).offsetMicroSec = str2double(epochxml.Children(f).Children(c).Children.Data);
                    end
                end
        end
    end
end
for i = 2:length(epoch)
    epoch(i).delay = (epoch(i).onsetMicroSec - epoch(i-1).offsetMicroSec) + epoch(i-1).delay;
end

EEG.event = struct;
evIdx     = 0;
% ID #0005
eventFiles = dir(fullfile(mffName, 'Events_*.xml'));

for i = 1:length(eventFiles)
    fname = fullfile(eventFiles(i).folder, eventFiles(i).name);
    eventsxml = parseXML(fname);
    for f = 1:size(eventsxml.Children, 2)
        switch eventsxml.Children(f).Name
            case 'event'
                evIdx = evIdx+1;
                thisEvent = eventsxml.Children(f).Children;
                for g = 1:size(thisEvent, 2)
                    switch thisEvent(g).Name
                        case 'beginTime'
                            % Calculate the onset of the event in samples, i.e.
                            % (eventTime - startTime) * sampling rate + 1;
                            msdiff = mff_date_to_ms(thisEvent(g).Children.Data) - mff_date_to_ms(EEG.etc.amp_startdate);
                            % ID #0011
                            % adjust onset latency for any missing blocks due to epochs
                            if length(epoch) > 1
                                for e = length(epoch):-1:1
                                    if (msdiff*1000) >= epoch(e).onsetMicroSec
                                        msdiff = msdiff - (epoch(e).delay/1000);
                                    end
                                end
                            end
                            EEG.event(evIdx).latency = (msdiff/1000) * EEG.srate + 1;
                        case 'duration'
                            EEG.event(evIdx).duration = (str2double(thisEvent(g).Children.Data) / 1000) * EEG.srate;
                        case 'code'
                            type = thisEvent(g).Children.Data;
                            type(~isstrprop(type, 'alphanum')) = '';
                            type = lower(matlab.lang.makeValidName(type));
                            EEG.event(evIdx).type = type;
                    end
                end
        end
    end
end