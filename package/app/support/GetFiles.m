%% listing all the files

function Files = GetFiles(store)
% ---------------------------------------------------------
% NOTE
% This function does not deal with files saved in nested derivative
% folders, e.g. <dataset>/derivatives/EEG-inspect/derivatives/EEG-clean/sub-01
% It only loads files from subject directories within the root directory of
% the derivative pipeline e.g.
% <dataset>/derivatives/EEG-inspect/sub-01/<any subfolder>
% ---------------------------------------------------------
% Initialize
Files = table();
Files.Id = {}; 
Files.Path = {};
Files.SubId = {};
Files.Type = {};
Files.KeyVals = {};
Files.JSON = {};
Files.channels = {};
Files.chanlocs = {};
Files.events = {};
Files.history = {};
Files.Status = {};
Files.ErrorMessage = {};
Files.PrevState = {};
% Allowed extensions
Extensions = {'.set', '.edf', '.mat'};
%% Init structures(a variable with the following fields: name, folder, data,bytes,isdeir,datenum)
RawFiles = dir('imsureidontexist.xyz');
DerFiles = RawFiles;
FstLvlFiles = RawFiles;

% Scan for all files with these extensions
fprintf('>> BIDS: Scanning for files in your database...\n')
startTime = now(); %#ok<TNOW1>
for i = 1:length(Extensions)
    % Scan for raw files
    RawFiles = [RawFiles; dir(fullfile(store.ds.path, 'rawdata', 'sub-*', '**', ['sub-*_eeg', Extensions{i}]))]; %#ok<AGROW> 
    % Loop through the derivative modalities and scan for files in each sub-directory
    Modalities = dir([store.ds.path, '/derivatives']);
    for j = 1:length(Modalities)
        % Dont bother with the '.' and '..' paths, or any files
        if strcmpi(Modalities(j).name(1), '.')
            continue
        end
        if ~Modalities(j).isdir
            continue
        end
        if length(Modalities(j).name) < 3
            continue
        end
        if ~strcmpi(Modalities(j).name(1:3), 'EEG')
            continue
        end
        % Skip first-level output directories
        if regexpIdx(Modalities(j).name, '-output-fstlvl')
            continue
        end
        DerFiles = [DerFiles; dir(fullfile(store.ds.path, 'derivatives', Modalities(j).name, 'sub-*', '**', ['sub-*', Extensions{i}]))]; %#ok<AGROW> 
    end
    % Finally get all the first-level files
    FstLvlFiles = [FstLvlFiles; dir(fullfile(store.ds.path, 'derivatives', '*-output-fstlvl', 'sub-*', '**', ['sub-*', Extensions{i}]))]; %#ok<AGROW> 
end

fprintf('>> BIDS: Found %i files in %.0f seconds.\n', length(RawFiles) + length(DerFiles) + length(FstLvlFiles), (now()-startTime) * (24*60*60)); %#ok<TNOW1>
% ---------------------------------------------------------
% For each subject in the database, get all files and meta data
startTime = now(); %#ok<TNOW1>
for i = 1:size(store.ds.subjects, 1)
    % ---------------------------------------------------------
    % Set waitbar
    % ---------------------------------------------------------
    % Extract subject id and name
    thisSubjectFileIds = cell(0);
    SubId = store.ds.subjects.Id{i};
    Name = store.ds.subjects.Name{i};
    % ---------------------------------------------------------
    % Get all the raw files of this subject
    % # ID0015
    idx = regexpIdx({RawFiles.name}, [Name, '_']);
    FileList = RawFiles(idx);
    [Files, thisSubjectFileIds] = AddFilesToState(Files, SubId, FileList, 'raw', thisSubjectFileIds);
    % ---------------------------------------------------------
    % Get all the derivative files of this subject
    idx = regexpIdx({DerFiles.name}, [Name, '_']);
    FileList = DerFiles(idx);
    [Files, thisSubjectFileIds] = AddFilesToState(Files, SubId, FileList, 'derivative', thisSubjectFileIds);
    % ---------------------------------------------------------
    % Get all the first level output files of this subject
    idx = regexpIdx({FstLvlFiles.name}, [Name, '_']);
    FileList = FstLvlFiles(idx);
    [Files, thisSubjectFileIds] = AddFilesToState(Files, SubId, FileList, 'fstlvl', thisSubjectFileIds);
    % ---------------------------------------------------------
    % Add the file ids to the subject document
    store.ds.subjects.FileIds{i} = thisSubjectFileIds;
    % ---------------------------------------------------------
    % Command Window
    fprintf('>> BIDS: %i files loaded for subject %s.\n', length(thisSubjectFileIds), Name)
end
fprintf('>> BIDS: Loading dataset took %.0f seconds.\n', (now()-startTime) * (24*60*60)); %#ok<TNOW1>
end

