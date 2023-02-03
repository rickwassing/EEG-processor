function [EEG, Warnings] = Analysis_ICA(EEG, Settings, RejChans, Warnings)

if Settings.DoICA
    if ~isempty(RejChans)
        Include = find(...
            ~ismember({EEG.chanlocs.labels}, RejChans) & ...
            ismember({EEG.chanlocs.type}, 'EEG') ...
            );
    else
        Include = find(...
            ismember({EEG.chanlocs.type}, 'EEG') ...
            );
    end
    try
        % We must filter the data above 1 Hz, so store the unfiltered data
        % so we can put it back later
        urdata = EEG.data;
        % Apply 2 Hz highpass filter
        % Dimigen (2020) Optimizing the ICA-based removal of ocular EEG 
        % artifacts from free viewing experiments. Neuroimage. (207) 116117
        FilterOrder = pop_firwsord('hamming', EEG.srate, 2);
        EEG = pop_firws(EEG, 'fcutoff', 2, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', FilterOrder, 'minphase', 0);
        % Run ICA
        fprintf('>> BIDS: Performing independent component analysis on %i good EEG channels in file ''%s''.\n', length(Include), EEG.setname)
        T = now;
        if strcmpi(EEG.ref, 'averef') && isempty(RejChans)
            EEG = pop_runica(EEG, ...
                'icatype', 'runica', ...
                'chanind', Include, ...
                'extended', 1, ...
                'pca', EEG.nbchan-1 ...
                );
        else
            EEG = pop_runica(EEG, ...
                'icatype', 'runica', ...
                'chanind', Include, ...
                'extended', 1 ...
                );
        end
        % Automatic classification of components
        EEG = pop_iclabel(EEG, 'default');
        % Automatically flag components for rejection if their probability
        % to be eye, heart, or muscle artefact is over 80%
        EEG = pop_icflag(EEG, [...
            NaN, NaN; ... % Brain
            0.8, 1; ...   % Muscle
            0.8, 1; ...   % Eye
            0.8, 1; ...   % Heart
            NaN, NaN; ... % Line noise
            NaN, NaN; ... % Channel noise
            NaN NaN ...   % Other
            ]);
        EEG.etc.rej_components = asrow(find(EEG.reject.gcompreject));
        % Put the non-filtered data back
        EEG.data = urdata;
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
    catch ME
        % Put the non-filtered data back
        EEG.data = urdata;
        % Display warning
        fprintf('>> BIDS: Warning, ICA did not converge, no ICA performed.\n')
        printME(ME)
        Warnings = [Warnings; {'ICA did not converge, no ICA performed'}];
        Warnings = [Warnings; {'-----'}];
    end
else
    fprintf('>> BIDS: No ICA requested.\n')
end

end