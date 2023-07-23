function EEG = Proc_InterpolateChannels(EEG, chanIdx)
try
    EEG = eeg_interp(EEG, chanIdx);
catch ME
    % If the error is as follows then we can solve it by rounding the
    % channel coordinates to three significant digits, else rethrow the
    % error.
    if ~strcmpi(ME.message, 'X must be real and in the range (-1,1).')
        rethrow(ME)
    end
    % Save current channel locs to they can be reinserted at the end
    origchanlocs = EEG.chanlocs;
    % Round channel locations to three significant decimal points
    fields = {'X', 'Y', 'Z', 'sph_theta', 'sph_phi', 'sph_radius', 'theta', 'radius'};
    for i = 1:length(EEG.chanlocs)
        % If X is empty, there are no locations for this channel e.g., a
        % physiology channel (EMG, ECG, etc.).
        if isempty(EEG.chanlocs(i).X)
            continue
        end
        % For all prespecified fields
        for j = 1:length(fields)
            % Check if field exists, and if so, round to 3 significant digits.
            if isfield(EEG.chanlocs, fields{j})
                EEG.chanlocs(i).(fields{j}) = round(EEG.chanlocs(i).(fields{j}), 3);
            end
        end
    end
    % Now run the interpolation
    EEG = eeg_interp(EEG, chanIdx);
    % And reinsert the original channel locations
    EEG.chanlocs = origchanlocs;
end
end
