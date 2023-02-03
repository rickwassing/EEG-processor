function EEG = Proc_TemporalFilter(EEG, Settings)

if Settings.DoFilter
    % Select EEG channels only
    chanIdx = find(strcmpi({EEG.chanlocs.type}, 'EEG'));
    tmp = pop_select(EEG, 'channel', chanIdx);
    % Do notch filter
    if Settings.FilterSettings.DoNotch
        fprintf('>> BIDS: %i Hz notch filter\n', Settings.FilterSettings.Notch)
        T = now;
        fcutoff = [Settings.FilterSettings.Notch-Settings.FilterSettings.TransitionBW*2, Settings.FilterSettings.Notch+Settings.FilterSettings.TransitionBW*2];
        forder = pop_firwsord(lower(Settings.FilterSettings.WindowType), EEG.srate, Settings.FilterSettings.TransitionBW);
        tmp = pop_firws(tmp, ...
            'fcutoff', fcutoff, ...
            'ftype', 'bandstop', ...
            'wtype', lower(Settings.FilterSettings.WindowType), ...
            'forder', forder, ...
            'minphase', 0);
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
        % Save the settings to the JSON struct
        if isfield(EEG.etc, 'JSON')
            if isfield(EEG.etc.JSON, 'SoftwareFilters')
                if ~isstruct(EEG.etc.JSON.SoftwareFilters)
                    EEG.etc.JSON.SoftwareFilters = struct();
                    idx = 1;
                elseif isfield(EEG.etc.JSON.SoftwareFilters, 'BandStop')
                    idx = length(EEG.etc.JSON.SoftwareFilters.BandStop)+1;
                else
                    idx = 1;
                end
            else
                idx = 1;
            end
        else
            idx = 1;
        end
        EEG.etc.JSON.SoftwareFilters.BandStop(idx).FilterType = 'Windowed sinc FIR filter';
        EEG.etc.JSON.SoftwareFilters.BandStop(idx).Window = Settings.FilterSettings.WindowType;
        EEG.etc.JSON.SoftwareFilters.BandStop(idx).PassBand = fcutoff;
        EEG.etc.JSON.SoftwareFilters.BandStop(idx).TransitionBandwidth = Settings.FilterSettings.TransitionBW;
        EEG.etc.JSON.SoftwareFilters.BandStop(idx).Order = forder;
    end
    % Do bandpass filter
    if Settings.FilterSettings.DoBandpass
        fprintf('>> BIDS: %.4g to %.4g Hz bandpass filter\n', Settings.FilterSettings.Highpass, Settings.FilterSettings.Lowpass)
        T = now;
        forder = pop_firwsord(lower(Settings.FilterSettings.WindowType), EEG.srate, Settings.FilterSettings.TransitionBW);
        tmp = pop_firws(tmp, ...
            'fcutoff', [Settings.FilterSettings.Highpass, Settings.FilterSettings.Lowpass], ...
            'ftype', 'bandpass', ...
            'wtype', lower(Settings.FilterSettings.WindowType), ...
            'forder', forder, ...
            'minphase', 0);
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
        % Save the settings to the JSON struct
        if isfield(EEG.etc, 'JSON')
            if isfield(EEG.etc.JSON, 'SoftwareFilters')
                if ~isstruct(EEG.etc.JSON.SoftwareFilters)
                    EEG.etc.JSON.SoftwareFilters = struct();
                    idx = 1;
                elseif isfield(EEG.etc.JSON.SoftwareFilters, 'BandPass')
                    idx = length(EEG.etc.JSON.SoftwareFilters.BandPass)+1;
                else
                    idx = 1;
                end
            else
                idx = 1;
            end
        else
            idx = 1;
        end
        EEG.etc.JSON.SoftwareFilters.BandPass(idx).FilterType = 'Windowed sinc FIR filter';
        EEG.etc.JSON.SoftwareFilters.BandPass(idx).Window = Settings.FilterSettings.WindowType;
        EEG.etc.JSON.SoftwareFilters.BandPass(idx).PassBand = [Settings.FilterSettings.Highpass, Settings.FilterSettings.Lowpass];
        EEG.etc.JSON.SoftwareFilters.BandPass(idx).TransitionBandwidth = Settings.FilterSettings.TransitionBW;
        EEG.etc.JSON.SoftwareFilters.BandPass(idx).Order = forder;
    end
    % Save filtered EEG data
    EEG.data(chanIdx, :) = tmp.data;
    clear tmp;
else
    % Note in the JSON that no filters have been applied
    if isfield(EEG.etc.JSON, 'SoftwareFilters')
        if isstruct(EEG.etc.JSON.SoftwareFilters)
            if isempty(fieldnames(EEG.etc.JSON.SoftwareFilters))
                EEG.etc.JSON.SoftwareFilters = 'none';
            end
        else
            EEG.etc.JSON.SoftwareFilters = 'none';
        end
    else
        EEG.etc.JSON.SoftwareFilters = 'none';
    end
end

end
