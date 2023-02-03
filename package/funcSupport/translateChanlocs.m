function chanlocs = translateChanlocs(hdr)
% --------------------------------------------------
% Tries to map the labels of the channels in the header to that of the
% 10-20 system.
% --------------------------------------------------
% Init
chanlocs = struct();
% --------------------------------------------------
% Load the extended 10-20 electrode positions
reflocs = template_to_chanlocs(which('Compumedics-257.sfp'));
% Move M1 and M2 to the bottom
idx = strcmpi({reflocs.labels}, 'M1') | strcmpi({reflocs.labels}, 'M2');
reflocs = [reflocs(~idx), reflocs(idx)];
% --------------------------------------------------
% For each channel in the header, try to find the channel label, type, position,
% reference, unit
for i = 1:length(hdr.label)
    isEEG = cellfun(@(lbl) contains(lower(hdr.label{i}), lower(lbl)), {reflocs.labels});
    if any(isEEG) && ismember(hdr.label{i}(1), {'A', 'M', 'F', 'C', 'P', 'T', 'O'})
        idx = find(isEEG, 1, 'first');
        chanlocs(i).labels = reflocs(idx).labels;
        chanlocs(i).urlabels = hdr.label{i};
        chanlocs(i).X = reflocs(idx).X;
        chanlocs(i).Y = reflocs(idx).Y;
        chanlocs(i).Z = reflocs(idx).Z;
        chanlocs(i).sph_theta = reflocs(idx).sph_theta;
        chanlocs(i).sph_phi = reflocs(idx).sph_phi;
        chanlocs(i).sph_radius = reflocs(idx).sph_radius;
        chanlocs(i).theta = reflocs(idx).theta;
        chanlocs(i).radius = reflocs(idx).radius;
        chanlocs(i).type = 'EEG';
        chanlocs(i).unit = hdr.chanunit{i};
        chanlocs(i).ref = 'common'; % assume the reference is a common ref
        if ... % or overwrite the ref if the chan-label contains this info
                contains(lower(hdr.label{i}), 'm12') || ...
                contains(lower(hdr.label{i}), 'm1m2') || ...
                contains(lower(hdr.label{i}), 'm1-m2') || ...
                contains(lower(hdr.label{i}), 'm1_m2') || ...
                contains(lower(hdr.label{i}), 'a12') || ...
                contains(lower(hdr.label{i}), 'a1a2') || ...
                contains(lower(hdr.label{i}), 'a1-a2') || ...
                contains(lower(hdr.label{i}), 'a1_a2')
            chanlocs(i).ref = {'M1', 'M2'};
        elseif...
                contains(lower(hdr.label{i}), 'm1') || ...
                contains(lower(hdr.label{i}), 'a1')
            chanlocs(i).ref = 'M1';
        elseif...
                contains(lower(hdr.label{i}), 'm2') || ...
                contains(lower(hdr.label{i}), 'a2')
            chanlocs(i).ref = 'M2';
        end
    else
        % It's a phys channel
        if contains(lower(hdr.label{i}), 'eog')
            type = 'EOG';
        elseif contains(lower(hdr.label{i}), 'e1')
            type = 'EOG';
        elseif contains(lower(hdr.label{i}), 'e2')
            type = 'EOG';
        elseif contains(lower(hdr.label{i}), 'ecg')
            type = 'ECG';
        elseif contains(lower(hdr.label{i}), 'ekg')
            type = 'ECG';
        elseif contains(lower(hdr.label{i}), 'emg')
            type = 'EMG';
        elseif contains(lower(hdr.label{i}), 'chin')
            type = 'EMG';
        elseif contains(lower(hdr.label{i}), 'leg')
            type = 'EMG';
        elseif contains(lower(hdr.label{i}), 'limb')
            type = 'EMG';
        elseif contains(lower(hdr.label{i}), 'resp')
            type = 'RESP';
        elseif contains(lower(hdr.label{i}), 'abdo')
            type = 'RESP';
        elseif contains(lower(hdr.label{i}), 'thor')
            type = 'RESP';
        elseif contains(lower(hdr.label{i}), 'snore')
            type = 'RESP';
        elseif contains(lower(hdr.label{i}), 'nasal')
            type = 'RESP';
        elseif contains(lower(hdr.label{i}), 'spo2')
            type = 'PPG';
        elseif contains(lower(hdr.label{i}), 'pleth')
            type = 'PPG';
        elseif contains(lower(hdr.label{i}), 'therm')
            type = 'TEMP';
        else
            type = 'MISC';
        end
        chanlocs(i).labels = hdr.label{i};
        chanlocs(i).urlabels = hdr.label{i};
        chanlocs(i).X = zeros(0);
        chanlocs(i).Y = zeros(0);
        chanlocs(i).Z = zeros(0);
        chanlocs(i).sph_theta = zeros(0);
        chanlocs(i).sph_phi = zeros(0);
        chanlocs(i).sph_radius = zeros(0);
        chanlocs(i).theta = zeros(0);
        chanlocs(i).radius = zeros(0);
        chanlocs(i).type = type;
        chanlocs(i).unit = hdr.chanunit{i};
        chanlocs(i).ref = zeros(0);
    end
end
end