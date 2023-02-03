% =========================================================
% FUNCTION: Renames a File in the Database, note, does not rename the directory
function File = RenameFile(app, File, NewKeyVals)
% Extract all the parts of the full file path
[CurrentPath, CurrentDataFilename, DataExtension] = fileparts(File.Path);
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
if exist(File.Path) == 0 %#ok<EXIST> 
    sel = uiconfirm(app.UIFigure, {'Cannot change the filename. File does not exist:', CurrentDataFilename}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status = 'error';
    return
end
% Check that the new file doe not currently exists
if exist([CurrentPath, '/', NewDataFilename, DataExtension]) ~= 0 %#ok<EXIST> 
    sel = uiconfirm(app.UIFigure, {'Cannot change the filename. The renamed file already exists:', NewDataFilename}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status = 'error';
    return
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
    File.Status = 'error';
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
    NewFullFilePath = [CurrentPath, '/', NewFilename, Extension];
    % Check if new filename already exists
    if exist(NewFullFilePath) ~= 0 %#ok<EXIST> 
        sel = uiconfirm(app.UIFigure, {'Cannot change the filename. The renamed file already exists:', [NewFilename, Extension]}, 'Error', ...
            'Options',{'OK'},...
            'DefaultOption', 'OK', ...
            'Icon', 'error'); %#ok<NASGU>
        File.Status = 'error';
        return
    end
    % ---------------------------------------------------------
    % Create command
    OSOldFullFilePath = strrep([CurrentPath, '/', CurrentFilename, Extension], '/', filesep);
    OSNewFullFilePath = strrep(NewFullFilePath, '/', filesep);
    if ispc
        [~, OSNewFileName] = fileparts(OSNewFullFilePath);
        cmd = ['Rename "', OSOldFullFilePath, '" ', OSNewFileName, Extension];
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
        File.Status = 'error';
        return
    end
end
% Renaming was successful, change the File in the state
File.Path = [CurrentPath, '/', NewDataFilename, DataExtension];
File.KeyVals = NewKeyVals;
end