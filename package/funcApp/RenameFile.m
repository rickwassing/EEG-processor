% =========================================================
% FUNCTION: Renames a File in the Database, note, does not rename the directory
function File = RenameFile(app, File, NewKeyVals)
% Check that only one file was provided
if size(File, 1) ~= 1
    error('Input must be one file only')
end
% Extract all the parts of the full file path
[CurrentPath, CurrentDataFilename, DataExtension] = fileparts(File.Path{1});
% Extract key value pairs
CurrentKeyVals = filename2struct(CurrentDataFilename);
DataKeyVals = filename2struct(CurrentDataFilename);
% Update key values
Keys = fieldnames(DataKeyVals);
for k = 1:length(Keys)
    if strcmpi(Keys{k}, 'filetype')
        continue
    end
    if isfield(NewKeyVals, Keys{k})
        DataKeyVals.(Keys{k}) = NewKeyVals.(Keys{k});
    end
end
% Set new data filename
NewDataFilename = struct2filename(DataKeyVals);
% Check that the new filename is actually different from the existing one
if strcmpi(CurrentDataFilename, NewDataFilename)
    return
end
% Check that the file currently exists
if exist(File.Path{1}) == 0 %#ok<EXIST> 
    sel = uiconfirm(app.UIFigure, {'Cannot change the filename. File does not exist:', CurrentDataFilename}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status{1} = 'error';
    return
end
% Check that the new file doe not currently exists
if exist([CurrentPath, '/', NewDataFilename, DataExtension]) ~= 0 %#ok<EXIST> 
    sel = uiconfirm(app.UIFigure, {'Cannot change the filename. The renamed file already exists:', NewDataFilename}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status{1} = 'error';
    return
end
NewKeyVals = filename2struct(NewDataFilename);
% Set new filepath (check whether we need to change the path)
% if the session value has changed, and this file is within a session
% directory, then we must also change the directory name
if isfield(CurrentKeyVals, 'ses') && isfield(NewKeyVals, 'ses')
    if ~strcmpi(CurrentKeyVals.ses, NewKeyVals.ses) && contains(CurrentPath, 'ses-')
        changePathName = true;
    else
        changePathName = false;
    end
end
if changePathName
    % Get the name of the new directory
    NewPath = strrep(CurrentPath, ['ses-', CurrentKeyVals.ses], ['ses-', NewKeyVals.ses]);
    % If it does not exist yet, make it
    if exist(NewPath, 'dir') == 0
        CreateNewDirectory(NewPath)
    end
end
% Find the file and all sidecar files
RootName = cellfun(@(key, val) [key, '-', val], fieldnames(CurrentKeyVals), struct2cell(CurrentKeyVals), 'UniformOutput', false);
RootName = strjoin(RootName(1:end-1), '_');
Files2Process = dir([CurrentPath, '/', RootName '_*.*']);
if isempty(Files2Process)
    sel = uiconfirm(app.UIFigure, {'Cannot change the filename. No files found that match:', CurrentDataFilename}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status{1} = 'error';
    return
end
% Ok, go on to process each file
for i = 1:length(Files2Process)
    [~, CurrentFilename, Extension] = fileparts(Files2Process(i).name);
    % Extract key value pairs
    KeyVals = filename2struct(CurrentFilename);
    % Update key values
    Keys = fieldnames(KeyVals);
    for k = 1:length(Keys)
        if strcmpi(Keys{k}, 'filetype')
            continue
        end
        if isfield(NewKeyVals, Keys{k})
            KeyVals.(Keys{k}) = NewKeyVals.(Keys{k});
        end
    end
    % Set new filename
    NewFilename = struct2filename(KeyVals);
    if changePathName
        NewFullFilePath = [NewPath, '/', NewFilename, Extension];
    else
        NewFullFilePath = [CurrentPath, '/', NewFilename, Extension];
    end
    % Check if new filename already exists
    if exist(NewFullFilePath) ~= 0 %#ok<EXIST> 
        sel = uiconfirm(app.UIFigure, {'Cannot change the filename. The renamed file already exists:', [NewFilename, Extension]}, 'Error', ...
            'Options',{'OK'},...
            'DefaultOption', 'OK', ...
            'Icon', 'error'); %#ok<NASGU>
        File.Status{1} = 'error';
        return
    end
    % ---------------------------------------------------------
    % Create command
    OSOldFullFilePath = strrep([CurrentPath, '/', CurrentFilename, Extension], '/', filesep);
    OSNewFullFilePath = strrep(NewFullFilePath, '/', filesep);
    if ispc
        cmd = ['move "', OSOldFullFilePath,'" "', OSNewFullFilePath, '"'];
    else
        cmd = ['mv "', OSOldFullFilePath,'" "', OSNewFullFilePath, '"'];
    end
    % ---------------------------------------------------------
    % Run command
    [status, cmdout] = system(cmd);
    fprintf('>> BIDS: Renamed\n>> BIDS: ''/%s'' to\n>> BIDS: ''/%s'' in path\n>> BIDS: ''%s''\n', [CurrentFilename, Extension], [NewFilename, Extension], CurrentPath)
    if status ~= 0
        sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when renaming a file.', cmdout}, 'Error', ...
            'Options',{'Ok'},...
            'DefaultOption', 'Ok', ...
            'Icon', 'error'); %#ok<NASGU>
        File.Status{1} = 'error';
        return
    end
end
% Renaming was successful, change the File in the state
if changePathName
    File.Path{1} = [NewPath, '/', NewDataFilename, DataExtension];
else
    File.Path{1} = [CurrentPath, '/', NewDataFilename, DataExtension];
end
File.KeyVals{1} = NewKeyVals;
% If the old directory is empty, delete it
RemainingFiles = dir([CurrentPath, '/sub-*']);
RemainingFiles(strcmpi({RemainingFiles.name}, '.') | strcmpi({RemainingFiles.name}, '..')) = [];
if isempty(RemainingFiles)
    DeleteDir(app, CurrentPath);
end
end