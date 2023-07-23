function EEG = check_chanlocs(EEG, overwritedataset)

% Checks that the orientation of the channel locations are correct
% The low to high values of the variable 'X' encodes P -> A, and 'Y' encodes R -> L
%      +X
%       |
% +Y ---|--- -Y
%       |
%      -X

% Assume the dataset is ok
issuedetected = false;

% Check what system it is
[~, system] = ishdeeg({EEG.chanlocs.labels});
% Extract indices of channels on either size of both X and Y axes
switch system
    case 'egi257'
        % Check orientation of A-P ('E31' to 'E137') and L-R ('E70' to 'E193')
        idx.A = find(strcmpi({EEG.chanlocs.labels}, 'E31'));
        idx.P = find(strcmpi({EEG.chanlocs.labels}, 'E137'));
        idx.L = find(strcmpi({EEG.chanlocs.labels}, 'E70'));
        idx.R = find(strcmpi({EEG.chanlocs.labels}, 'E193'));
    case 'compu257'
        % Check orientation of A-P ('Fpz' to 'Oz') and L-R ('T7' to 'T8')
        idx.A = find(strcmpi({EEG.chanlocs.labels}, 'Fpz'));
        idx.P = find(strcmpi({EEG.chanlocs.labels}, 'Oz'));
        idx.L = find(strcmpi({EEG.chanlocs.labels}, 'T7'));
        idx.R = find(strcmpi({EEG.chanlocs.labels}, 'T8'));
    otherwise
        return % We must assume it's ok...
end

% Due to issue #0012 the spherical coordinates are not correct, lets check
% them and correct them if required.

% Keep only cartesian coordinates (these were imported from the geoscan or template file)
newlocs = EEG.chanlocs;
origfields = fieldnames(EEG.chanlocs);
for i = 1:length(origfields)
    if ismember(origfields{i}, {'labels', 'X', 'Y', 'Z'})
        continue
    end
    newlocs = rmfield(newlocs, origfields{i});
end

% Check that orientation of the cartesian coordinates is correct
if (newlocs(idx.A).X - newlocs(idx.P).X) < 0 % A minus P should be positive
    issuedetected = true;
    fprintf('>> BIDS: Checking channel-locations. Flipping X-direction.\n')
    % Flip X
    for i = 1:length(newlocs)
        newlocs(i).X = -1*newlocs(i).X;
    end
end
if (newlocs(idx.L).Y - newlocs(idx.R).Y) < 0 % L minus R should be positive
    issuedetected = true;
    fprintf('>> BIDS: Checking channel-locations. Flipping Y-direction.\n')
    % Flip Y
    for i = 1:length(newlocs)
        newlocs(i).Y = -1*newlocs(i).Y;
    end
end

% Now re-compute the spherical coordinates
newlocs = convertlocs(newlocs, 'cart2topo');

% Check that the 'sph_theta' variable is unchanged
if sum(abs([EEG.chanlocs.sph_theta] - [newlocs.sph_theta])) > 1
    % Issue #0012 detected, when importing the geoscan we correctly changed
    % the Y-variable, but did not update the spherical coordinates.
    % This is now corrected in 'newlocs'.
    fprintf('>> BIDS: Checking channel-locations. Recalculating theta and radius.\n')
    issuedetected = true;
end

% Add back any fields that we removed earlier
if issuedetected
    newfields = fieldnames(newlocs);
    missingfields = setdiff(origfields, newfields);
    for i = 1:length(missingfields)
        for j = 1:length(newlocs)
            newlocs(j).(missingfields{i}) = EEG.chanlocs(j).(missingfields{i});
        end
    end
    % Re-set the chanlocs variable in the 'EEG' structure
    EEG.chanlocs = newlocs;
end

% ID #0019: round channel locations to nearest 6 decimal points
fields = {'X', 'Y', 'Z', 'sph_theta', 'sph_phi', 'sph_radius', 'theta', 'radius'};
for i = 1:length(EEG.chanlocs)
    if isempty(EEG.chanlocs(i).X)
        continue
    end
    for j = 1:length(fields)
        if isfield(EEG.chanlocs, fields{j})
            EEG.chanlocs(i).(fields{j}) = round(EEG.chanlocs(i).(fields{j}), 6);
        end
    end
end
% Overwrite the data if necessary
if issuedetected && overwritedataset
    fprintf('>> BIDS: Checking channel-locations. Re-saving channel locations.\n')
    [~, ~, extension] = fileparts(EEG.filename);
    switch extension
        case '.mat'
            SaveDataset(EEG, 'matrix');
        otherwise
            SaveDataset(EEG, 'header');
    end
end

end