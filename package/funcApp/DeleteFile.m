% =========================================================
% FUNCTION: Deletes a File from the Database
function File = DeleteFile(app, File)
% Extract the path
Path = fileparts(File.Path);
% Find the file and all sidecar files
RootName = cellfun(@(key, val) [key, '-', val], fieldnames(File.KeyVals), struct2cell(File.KeyVals), 'UniformOutput', false);
RootName = strjoin(RootName(1:end-1), '_');
Files2Process = dir([Path, '/', RootName '_*.*']);
if isempty(Files2Process)
    sel = uiconfirm(app.UIFigure, {'Cannot delete the filename. No files found that match:', RootName}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status = 'error';
    return
end % Ok, go on to delete these files
% ---------------------------------------------------------
% Create the command
ArgIn = strrep(['"', Path, '/', RootName, '_"*'], '/', filesep);
if ispc
    cmd = ['del \f ', ArgIn];
else
    cmd = ['rm -f -v ', ArgIn];
end
% ---------------------------------------------------------
% Run command
[status, cmdout] = system(cmd);
if status ~= 0
    sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when deleting a file.', cmdout}, 'Error', ...
        'Options',{'Ok'},...
        'DefaultOption', 'Ok', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status = 'error';
end % Ok, file is deleted
% ---------------------------------------------------------
% Set the file's status
File.Status = 'deleted';
end
