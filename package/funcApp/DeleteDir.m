% =========================================================
% FUNCTION: Deletes a directory from the database disk
function hasError = DeleteDir(app, path)
% Assume everything is fine
hasError = false;
% Check that the path currently exists
if exist(path, 'dir') == 0
    sel = uiconfirm(app.UIFigure, {'Cannot delete the directory. It does not exist:', path}, ...
        'Error', ...
        'Options',{'OK'},...
        'DefaultOption', 'OK', ...
        'Icon', 'error'); %#ok<NASGU>
    hasError = true;
    return
end % Ok, directory exists, go on to delete it and all its contents
% ---------------------------------------------------------
% Create the command
if ispc
    cmd =  ['rd /s /q "', path, '"'];
else
    cmd =  ['rm -rf "', path, '"'];
end
% ---------------------------------------------------------
% Print to command window
fprintf('>> BIDS: Deleting directory ''%s''\n', path)
% ---------------------------------------------------------
% Execute the command
[status, cmdout] = system(cmd);
% If the directory is not empty, on MSWindows, it returns exit code 145
if status ~= 0 && status ~= 145
    keyboard
    sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when deleting a directory.', cmdout}, 'Error', ...
        'Options',{'Ok'},...
        'DefaultOption', 'Ok', ...
        'Icon', 'error'); %#ok<NASGU>
    hasError = true;
end % Ok, directory is deleted

end
