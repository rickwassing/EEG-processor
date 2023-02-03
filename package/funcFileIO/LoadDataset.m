function EEG = LoadDataset(FullFilePath, Part)
% =========================================================
% Check what filetype to load
[~, ~, Extension] = fileparts(FullFilePath);
switch Extension
    % ---------------------------------------------------------
    case '.set'
        % ---------------------------------------------------------
        % LOAD THE EEGLAB FORMAT
        % ---------------------------------------------------------
        % Check whether to load the header and data, or only header
        switch Part
            case 'all'
                disp('>> BIDS: Reading complete dataset from EEGLAB file')
                EEG = pop_loadset(FullFilePath);
                disp('>> - Finished loading')
            otherwise
                disp('>> BIDS: Reading header information from EEGLAB file')
                fprintf('>> BIDS: %s\n', FullFilePath)
                load('-mat', FullFilePath, 'EEG');
                disp('>> - Finished loading')
        end
        % ---------------------------------------------------------
        % Check that the set-, filename and filepaths are correct
        [EEG.filepath, EEG.setname] = fileparts(FullFilePath);
        EEG.filepath = strrep(EEG.filepath, filesep, '/');
        EEG.filename = [EEG.setname, '.set'];
        EEG.datfile = [EEG.setname, '.fdt'];
        % ---------------------------------------------------------
    case '.mat'
        % ---------------------------------------------------------
        % Load MAT file
        tmp = load(FullFilePath);
        if ~isfield(tmp, 'EEG')
            EEG = struct();
            return
        end
        EEG = tmp.EEG;
        % ---------------------------------------------------------
        % Check that the set-, filename and filepaths are correct
        [EEG.filepath, EEG.filename] = fileparts(FullFilePath);
        EEG.filepath = strrep(EEG.filepath, filesep, '/');
        EEG.filename = [EEG.filename, '.mat'];
        % ---------------------------------------------------------
    otherwise
        disp('>> BIDS: Reading header information from file')
        fprintf('>> BIDS: %s\n', FullFilePath)
        % ---------------------------------------------------------
        % USE FIELDTRIP TO IMPRORT THE HEADER AND OR DATA
        % ---------------------------------------------------------
        % Create empty EEG structure and set filename and paths
        EEG = eeg_emptyset();
        [EEG.filepath, EEG.setname, Extension] = fileparts(FullFilePath);
        EEG.filename = [EEG.setname, Extension];
        % ---------------------------------------------------------
        % Get the filenames of the sidecar files
        % -----
        % Get keys and values
        KeysValues = filename2struct(EEG.setname);
        Keys = fieldnames(KeysValues); Keys(end) = [];
        Values = struct2cell(KeysValues); Values(end) = [];
        % -----
        % Generate filenames for all the sidecar files
        BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
        JSONFilename = [EEG.filepath, '/', EEG.setname, '.json'];
        ChannelFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'channels.tsv'}], '')];
        CoordFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'coordsystem.json'}], '')];
        EventsFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'events.tsv'}], '')];
        % ---------------------------------------------------------
        % Read header and insert meta information
        hdr = ft_read_header(FullFilePath);
        % ---------------------------------------------------------
        % Check the unit of the EEG data, if in milliV then multiply by 1000
        PhysDim = hdr.orig.PhysDim(hdr.orig.chansel, :);
        eegchans = find(strcmpi(hdr.chantype, 'EEG'), 1, 'first');
        if strcmpi(deblank(PhysDim(eegchans, :)), 'mV')
            multfactor = 1000;
        else
            multfactor = 1;
        end
        % ---------------------------------------------------------
        EEG.subject = KeysValues.sub;
        EEG.session = KeysValues.ses;
        EEG.nbchan = hdr.nChans;
        EEG.trials = hdr.nTrials;
        EEG.pnts = hdr.nSamples;
        EEG.srate = hdr.Fs;
        EEG.xmin = -hdr.nSamplesPre/EEG.srate;
        EEG.xmax = (EEG.pnts-hdr.nSamplesPre-1)/EEG.srate;
        EEG.times = EEG.xmin:1/EEG.srate:EEG.xmax;
        if isfield(hdr.orig, 'T0')
            EEG.etc.T0 = hdr.orig.T0;
            EEG.etc.rec_startdate = datenum(EEG.etc.T0);
        end
        % ---------------------------------------------------------
        % CHANNEL LOCATIONS AND REJECTED CHANNELS
        Channels = readtable(ChannelFilename, 'delimiter', '\t', 'FileType', 'text');
        if any(strcmpi(Channels.status, 'bad'))
            EEG.etc.rej_channels = asrow(Channels.name(strcmpi(Channels.status, 'bad')));
        end
        % Check if electrode positions exist...
        if isfield(hdr.orig, 'chanlocs')
            % ... yes they do, just copy them over
            EEG.chanlocs = hdr.orig.chanlocs;
        else
            % ... no they don't, check if the electrode positions exist in
            % the header...
            if ~isfield(hdr, 'elec')
                % ... no, header does not contain electrode positions, try
                % to translate the channel labels using the 10-20 template
                EEG.chanlocs = translateChanlocs(hdr);
            else
                % ... yes, header contains channel locations, use them to
                % construct the chanlocs file
                tmplocs = struct();
                for i = 1:length(hdr.elec.label)
                    tmplocs(i).labels = hdr.elec.label{i};
                    tmplocs(i).X = ifelse(isnan(hdr.elec.elecpos(i, 1)), [], hdr.elec.elecpos(i, 1));
                    tmplocs(i).Y = ifelse(isnan(hdr.elec.elecpos(i, 2)), [], hdr.elec.elecpos(i, 2));
                    tmplocs(i).Z = ifelse(isnan(hdr.elec.elecpos(i, 3)), [], hdr.elec.elecpos(i, 3));
                    xyz = [tmplocs(i).X, tmplocs(i).Y, tmplocs(i).Z];
                    if ~isempty(xyz)
                        [tmplocs(i).theta, tmplocs(i).radius] = cart2topo(xyz);
                        tmplocs(i).sph_radius = sqrt(tmplocs(i).X.^2 + tmplocs(i).Y.^2 + tmplocs(i).Z.^2);
                    else
                        tmplocs(i).theta = zeros(0);
                        tmplocs(i).radius = zeros(0);
                        tmplocs(i).sph_radius = zeros(0);
                    end
                end
                % Write and read temporary chanloc file
                writelocs(tmplocs, 'tmp.sfp', 'filetype', 'xyz');
                EEG.chanlocs = readlocs('tmp.sfp');
                delete('tmp.sfp');
                for i = 1:length(hdr.elec.label)
                    EEG.chanlocs(i).labels = hdr.elec.label{i};
                    EEG.chanlocs(i).type = hdr.chantype{i};
                    EEG.chanlocs(i).unit = hdr.chanunit{i};
                    EEG.chanlocs(i).ref = Channels.reference{i};
                end
                % Check what type of reference the EEG has
                Refs = unique([EEG.chanlocs(strcmpi({EEG.chanlocs.type}, 'EEG')).ref]);
                if length(Refs) > 1
                    EEG.ref = 'mixed';
                elseif strcmpi(Refs{1}, 'common')
                    EEG.ref = 'common';
                else
                    EEG.ref = 'unknown';
                end
                for i = 1:length(EEG.chanlocs)
                    if strcmpi(EEG.chanlocs(i).type, 'EEG')
                        continue
                    end
                    EEG.chanlocs(i).Y = zeros(0);
                    EEG.chanlocs(i).X = zeros(0);
                    EEG.chanlocs(i).Z = zeros(0);
                    EEG.chanlocs(i).sph_theta = zeros(0);
                    EEG.chanlocs(i).sph_phi = zeros(0);
                    EEG.chanlocs(i).sph_radius = zeros(0);
                    EEG.chanlocs(i).theta = zeros(0);
                    EEG.chanlocs(i).radius = zeros(0);
                    EEG.chanlocs(i).sph_theta_besa = zeros(0);
                    EEG.chanlocs(i).sph_phi_besa = zeros(0);
                end
            end
        end
        % ---------------------------------------------------------
        % CHANNEL INFO
        if isfield(hdr.orig, 'chaninfo')
            EEG.chaninfo = hdr.orig.chaninfo;
        elseif exist(CoordFilename, 'file') ~= 0
            Coordinates = jsondecode(fileread(CoordFilename));
            EEG.chaninfo = struct();
            Labels = fieldnames(Coordinates.AnatomicalLandmarkCoordinates);
            for i = 1:length(Labels)
                EEG.chaninfo.ndchanlocs(i).labels = Labels{i};
                EEG.chaninfo.ndchanlocs(i).X = Coordinates.AnatomicalLandmarkCoordinates.(Labels{i})(1);
                EEG.chaninfo.ndchanlocs(i).Y = Coordinates.AnatomicalLandmarkCoordinates.(Labels{i})(2);
                EEG.chaninfo.ndchanlocs(i).Z = Coordinates.AnatomicalLandmarkCoordinates.(Labels{i})(3);
                EEG.chaninfo.ndchanlocs(i).type = 'FID';
            end
            EEG.chaninfo.filename = CoordFilename;
            EEG.chaninfo.plotrad = [];
            EEG.chaninfo.shrink = [];
            switch Coordinates.EEGCoordinateSystem
                case {'ALS', 'ARS'}
                    EEG.chaninfo.nosedir = '+X';
                case {'PLS', 'PRS'}
                    EEG.chaninfo.nosedir = '-X';
                case {'LAS', 'RAS'}
                    EEG.chaninfo.nosedir = '+Y';
                case {'LPS', 'RPS'}
                    EEG.chaninfo.nosedir = '-Y';
                case {'LSA', 'RSA'}
                    EEG.chaninfo.nosedir = '+Z';
                case {'LSP', 'RSP'}
                    EEG.chaninfo.nosedir = '-Z';
            end
        end
        % ---------------------------------------------------------
        % EVENTS
        Events = readtable(EventsFilename, 'Delimiter', '\t', 'FileType', 'text');
        for i = 1:size(Events, 1)
            EEG.event(i).latency = Events.onset(i)*EEG.srate;
            EEG.event(i).duration = Events.duration(i)*EEG.srate;
            EEG.event(i).type = strrep(Events.trial_type{i}, 'artifact_', '');
            EEG.event(i).id = i;
            EEG.event(i).is_reject = ifelse(regexpIdx(Events.trial_type{i}, 'artifact'), true, false);
            if EEG.trials > 1
                EEG.event(i).epoch = ceil(EEG.event(i).latency/EEG.pnts);
            end
        end
        % ---------------------------------------------------------
        % ETCETERA
        if isfield(hdr.orig, 'etc')
            EEG.etc = hdr.orig.etc;
        end
        EEG.etc.JSON = jsondecode(fileread(JSONFilename));
        disp('>> - Finished loading header information')
        % ---------------------------------------------------------
        % Load data
        if strcmpi(Part, 'all')
            disp('>> BIDS: Reading data from file')
            fprintf('>> BIDS: %s\n', FullFilePath)
            EEG.data = single(ft_read_data([EEG.filepath, '/', EEG.filename]));
            eegchans = strcmpi({EEG.chanlocs.type}, 'EEG');
            EEG.data(eegchans, :) = multfactor .* EEG.data(eegchans, :);
            EEG.filepath = strrep(EEG.filepath, filesep, '/');
            % If it was an EDF file, the last channel is the event channel
            % and can be removed
            EEG.data(length(EEG.chanlocs)+1:end, :) = [];
            EEG.nbchan = size(EEG.data, 1);
            disp('>> - Finished loading')
        end
end
if strcmpi(Part, 'all')
    % ---------------------------------------------------------
    % Make sure the EEG channels appear first, then the PNS channels
    EEG = forceChannelOrder(EEG);
end
% ---------------------------------------------------------
% Make sure all event labels are lower-case and valid matlab names
EEG = forceValidEventType(EEG);
% ---------------------------------------------------------
% Make sure the channel locations are correct
EEG = check_chanlocs(EEG, true);
% ---------------------------------------------------------
% Make sure the EEG.times is in seconds
if isfield(EEG, 'times')
    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
end
% ---------------------------------------------------------
% Make sure we have a start date in 'datestr' format
if isfield(EEG.etc, 'rec_startdate')
    if isnumeric(EEG.etc.rec_startdate)
        EEG.etc.rec_startdate = datestr(EEG.etc.rec_startdate, 'yyyy-mm-ddTHH:MM:SS');
    end
end
if isfield(EEG.etc, 'amp_startdate')
    if isnumeric(EEG.etc.amp_startdate)
        EEG.etc.amp_startdate = datestr(EEG.etc.amp_startdate, 'yyyy-mm-ddTHH:MM:SS.FFF');
    end
end
if ~isfield(EEG.etc, 'rec_startdate') && isfield(EEG.etc, 'amp_startdate')
    EEG.etc.rec_startdate = EEG.etc.amp_startdate;
end

end
