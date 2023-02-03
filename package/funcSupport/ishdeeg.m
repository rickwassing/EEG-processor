function [bool, system] = ishdeeg(labels)
% Input 'labels' must be a cell array of channel labels.

% Get cranial channel names for all supported hd-eeg systems
[~, cranlabels] = hdeeg_scalpchannels('all');
% Extract the supported systems (i.e., fieldnames of the structure)
systems = fieldnames(cranlabels);
% Assume its not a HD-EEG unless proven otherwise
bool = false;
system = 'unknown';
% check if all cranial labels are in the list of labels
for s = 1:length(systems)
    if all(ismember(cranlabels.(systems{s}), labels))
        bool = true;
        system = systems{s};
        break
    end
end

end