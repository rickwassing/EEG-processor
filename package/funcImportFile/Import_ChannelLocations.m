function [EEG, urpibchanlocs, urpibdata] = Import_ChannelLocations(EEG, FileType, FullFilePath, DataType)

if ~isempty(EEG.chanlocs)
    % Remove EEG chanlocs
    idx = strcmpi({EEG.chanlocs.type}, 'EEG');
    urpibchanlocs = EEG.chanlocs(~idx);
    if ndims(EEG.data) == 3
        urpibdata = EEG.data(~idx, :, :);
    else
        urpibdata = EEG.data(~idx, :);
    end
    switch DataType
        case 'GRAEL'
            EEG.chanlocs = EEG.chanlocs(idx);
        otherwise
            EEG.chanlocs(:) = [];
    end
else
    urpibchanlocs = struct();
    urpibchanlocs(1) = [];
    urpibdata = [];
end
switch FileType
    case 'Geoscan'
        disp('>> BIDS: Importing channel locations from geoscan file')
        T = now;
        [chanlocs, EEG.chaninfo.ndchanlocs] = geoscan_to_chanlocs(FullFilePath);
        if strcmpi(DataType, 'COMPU257')
            N = 257; % The Compumedics net has 5 more scannable channels, but they are not relevant
            for i = 1:N
                chanlocs(i).labels = EEG.urchanlocs(i).labels;
            end
        else
            N = length(chanlocs);
        end
        fnames = fieldnames(chanlocs);
        for i = 1:N
            k = length(EEG.chanlocs)+1;
            for j = 1:length(fnames)
                EEG.chanlocs(k).(fnames{j}) = chanlocs(i).(fnames{j});
            end
        end
        EEG.chaninfo.filename = FullFilePath;
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
    case 'Nomenclature'
        disp('>> BIDS: Importing channel locations from 10-20 nomenclature labels')
        [chanlocs, EEG.chaninfo.ndchanlocs] = template_to_chanlocs(which('Compumedics-257.sfp'));
        for i = 1:length(EEG.chanlocs)
            if ~strcmpi(EEG.chanlocs(i).type, 'EEG')
                continue
            end
            idx = strcmpi(EEG.chanlocs(i).labels, {chanlocs.labels});
            if ~any(idx)
                error('Channel label ''%s'' does not adhere to nomenclature.', EEG.chanlocs(i).labels)
            end
            EEG.chanlocs(i).X = chanlocs(idx).X;
            EEG.chanlocs(i).Y = chanlocs(idx).Y;
            EEG.chanlocs(i).Z = chanlocs(idx).Z;
        end
        EEG.chanlocs = convertlocs(EEG.chanlocs, 'cart2topo');
    otherwise
        disp('>> BIDS: Importing channel locations from template file')
        T = now;
        [chanlocs, EEG.chaninfo.ndchanlocs] = template_to_chanlocs(which(FileType));
        % Copy over the fields to the EEG struct
        fnames = fieldnames(chanlocs);
        for i = 1:length(chanlocs)
            k = length(EEG.chanlocs)+1;
            for j = 1:length(fnames)
                EEG.chanlocs(k).(fnames{j}) = chanlocs(i).(fnames{j});
            end
        end
        EEG.chaninfo.filename = which(FileType);
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
end
if isempty(EEG.chanlocs)
    error('%s: Unexpected error with importing channel locations from %s.', EEG.filename, EEG.chaninfo.filename)
end
% Check that the orientation of the channel locations are correct
EEG = check_chanlocs(EEG, false);
% Add the channel clusters
EEG.chanlocs = channel_clusters(EEG.chanlocs, DataType);
% Finally, add the unit to the chanlocs
for i = 1:length(EEG.chanlocs)
    if isfield(EEG.chanlocs, 'unit')
        if ~isempty(EEG.chanlocs(i).unit)
            continue
        end
    end
    EEG.chanlocs(i).unit = 'uV';
end
for i = 1:length(urpibchanlocs)
    if ~isfield(urpibchanlocs, 'unit')
        urpibchanlocs(i).unit = 'unknown';
    elseif isempty(urpibchanlocs(i).unit)
        urpibchanlocs(i).unit = 'unknown';
    end
end

end
