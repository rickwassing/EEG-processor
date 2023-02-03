function [EEG, MFF] = Import_EmptySet(FileType, FullFilePath)
T = now;
switch lower(FileType)
    case 'mff'
        % initialise EEG structure
        MFF = mff_import_meta_data(FullFilePath);
        EEG = mff_newset(MFF);
    case 'compu257'
        EEG = compumedics_import_data(FullFilePath);
        MFF = [];
        [EEG.filepath, EEG.setname] = fileparts(FullFilePath);
        EEG.filename = [EEG.setname, '.set'];
    case 'tentwenty'
        EEG = tentwenty_import_data(FullFilePath);
        MFF = [];
        [EEG.filepath, EEG.setname] = fileparts(FullFilePath);
        EEG.filename = [EEG.setname, '.set'];
    case 'grael'
        EEG = grael_import_data(FullFilePath);
        MFF = [];
        [EEG.filepath, EEG.setname] = fileparts(FullFilePath);
        EEG.filename = [EEG.setname, '.set'];
    case 'set'
        % Load the data from the SET file
        EEG = pop_loadset(FullFilePath);
        MFF = [];
        % Double check some values
        [EEG.filepath, EEG.setname] = fileparts(FullFilePath);
        EEG.filename = [EEG.setname, '.set'];
        EEG.nbchan = size(EEG.data, 1);
        if EEG.nbchan < 257 && ~EEG.nbchan == 2
            error('%s: Data file contains %i channels, where at least 257 EEG channels is expected.', EEG.filename, EEG.nbchan)
        end
        if isempty(EEG.chanlocs)
            error('%s: Channel locations are missing.', EEG.filename)
        end
        if isempty(EEG.chanlocs(1).ref)
            error('%s: Reference channel is unknown.', EEG.filename)
        end
        if ndims(EEG.data) == 3
            EEG.trials = size(EEG.data, 3);
        else
            EEG.trials = 1;
        end
        EEG.pnts = size(EEG.data, 2);
        if length(EEG.times) > EEG.pnts
            EEG.times = EEG.times(1:EEG.pnts);
        elseif length(EEG.times) < EEG.pnts
            EEG.times = linspace(0, EEG.pnts * 1/EEG.srate, EEG.pnts);
        end
        EEG.xmin = 0;
        EEG.xmax = EEG.times(end);
end
% Create empty JSON structure
Specs = InstituteHardwareSpecs(FileType);
EEG.etc.JSON = struct();
EEG.etc.JSON.TaskName = '';
EEG.etc.JSON.InstitutionName = Specs.InstitutionName;
EEG.etc.JSON.InstitutionAddress = Specs.InstitutionAddress;
EEG.etc.JSON.Manufacturer = Specs.Manufacturer;
EEG.etc.JSON.ManufacturersModelName = Specs.ManufacturersModelName;
EEG.etc.JSON.SoftwareVersions = Specs.SoftwareVersions;
EEG.etc.JSON.EEGReference = '';
EEG.etc.JSON.EEGChannelCount = [];
EEG.etc.JSON.ECGChannelCount = [];
EEG.etc.JSON.EMGChannelCount = [];
EEG.etc.JSON.EOGChannelCount = [];
EEG.etc.JSON.MiscChannelCount = [];
EEG.etc.JSON.RecordingDuration = [];
EEG.etc.JSON.RecordingType = '';
EEG.etc.JSON.TrialCount = [];
EEG.etc.JSON.PowerLineFrequency = 50;
EEG.etc.JSON.HardwareFilters = Specs.HardwareFilters;
fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))

end
