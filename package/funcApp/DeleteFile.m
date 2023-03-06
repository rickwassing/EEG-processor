% =========================================================
% FUNCTION: Deletes a File from the Database
function [File, Next, Warnings] = DeleteFile(app, File)
% Init
Next = '';
Warnings = [];
% Check that only one file was provided
if size(File, 1) ~= 1
    error('Input must be one file only')
end
% Extract the path
Path = fileparts(File.Path{1});
% Find the file and all sidecar files
RootName = cellfun(@(key, val) [key, '-', val], fieldnames(File.KeyVals{1}), struct2cell(File.KeyVals{1}), 'UniformOutput', false);
RootName = strjoin(RootName(1:end-1), '_');
Files2Process = dir([Path, '/', RootName '_*.*']);
if isempty(Files2Process)
    sel = uiconfirm(app.UIFigure, {'Cannot delete the filename. No files found that match:', RootName}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    File.Status{1} = 'error';
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
    File.Status{1} = 'error';
end % Ok, file is deleted
% ---------------------------------------------------------
% Set the file's status
File.Status{1} = 'deleted';
% ---------------------------------------------------------
% What's next
Next = 'RemoveFile';
end
