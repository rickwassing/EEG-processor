function [is_hdeeg, system, iscropped] = ishdeeg(labels)
% Input 'labels' must be a cell array of channel labels.

% Get cranial channel names for all supported hd-eeg systems
[~, cranlabels] = hdeeg_scalpchannels('all');
% Extract the supported systems (i.e., fieldnames of the structure)
systems = fieldnames(cranlabels);
% Assume its not a HD-EEG unless proven otherwise
is_hdeeg = false;
system = 'unknown';
iscropped = false;
% check if all cranial labels are in the list of labels
for s = 1:length(systems)
    if all(ismember(lower(cranlabels.(systems{s})), lower(labels)))
        is_hdeeg = true;
        system = systems{s};
        iscropped = length(cranlabels.(systems{s})) == length(labels);
        break
    end
end

end