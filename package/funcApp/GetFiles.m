function Files = GetFiles(app)
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
Files.Status = {};
Files.ErrorMessage = {};
Files.PrevState = {};
% Allowed extensions
Extensions = {'.set', '.edf', '.mat'};
% Init structures
RawFiles = dir('imsureidontexist.xyz');
DerFiles = RawFiles;
FstLvlFiles = RawFiles;
% Scan for all files with these extensions
fprintf('>> BIDS: Scanning for files in your database...\n')
app.RenderWaitbar('Scanning for files in your database', -1);
startTime = now();
for i = 1:length(Extensions)
    % Scan for raw files
    RawFiles = [RawFiles; dir(fullfile(app.State.Protocol.Path, 'rawdata', 'sub-*', '**', ['sub-*_eeg', Extensions{i}]))]; %#ok<AGROW> 
    % Loop through the derivative modalities and scan for files in each sub-directory
    Modalities = dir([app.State.Protocol.Path, '/derivatives']);
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
        DerFiles = [DerFiles; dir(fullfile(app.State.Protocol.Path, 'derivatives', Modalities(j).name, 'sub-*', '**', ['sub-*', Extensions{i}]))]; %#ok<AGROW> 
    end
    % Finally get all the first-level files
    FstLvlFiles = [FstLvlFiles; dir(fullfile(app.State.Protocol.Path, 'derivatives', '*-output-fstlvl', 'sub-*', '**', ['sub-*', Extensions{i}]))]; %#ok<AGROW> 
end
fprintf('>> BIDS: Found %i files in %.0f seconds.\n', length(RawFiles) + length(DerFiles) + length(FstLvlFiles), (now()-startTime) * (24*60*60));
% ---------------------------------------------------------
% For each subject in the database, get all files and meta data
startTime = now();
for i = 1:size(app.State.Subjects, 1)
    % ---------------------------------------------------------
    % Set waitbar
    app.RenderWaitbar(sprintf('Adding files for subject %i of %i.', i, size(app.State.Subjects, 1)), i/size(app.State.Subjects, 1));
    % ---------------------------------------------------------
    % Extract subject id and name
    thisSubjectFileIds = cell(0);
    SubId = app.State.Subjects.Id{i};
    Name = app.State.Subjects.Name{i};
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
    app.State.Subjects.FileIds{i} = thisSubjectFileIds;
    % ---------------------------------------------------------
    % Command Window
    fprintf('>> BIDS: %i files loaded for subject %s.\n', length(thisSubjectFileIds), Name)
end
fprintf('>> BIDS: Loading dataset took %.0f seconds.\n', (now()-startTime) * (24*60*60));
end
