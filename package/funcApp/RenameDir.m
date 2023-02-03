function [NewPath, hasError] = RenameDir(app, CurrentPath, Name)
% ---------------------------------------------------------
% Initialize
CurrentPath = strrep(CurrentPath, filesep, '/');
hasError = false;
NewPath = CurrentPath;
% ---------------------------------------------------------
% Split the current path in its parts
PathParts = strsplit(CurrentPath, '/');
% Find the directories with the pattern 'sub-*'
idxSub = find(regexpIdx(PathParts, 'sub-*'));
% ---------------------------------------------------------
% Rename each directory that meets the pattern 'sub-*' in the full path
for i = 1:length(idxSub)
    % ---------------------------------------------------------
    % Create the sub-paths up until the subject path, both the current and new one
    thisPath = strjoin(PathParts(1:idxSub(i)), '/');
    newPath = strjoin([PathParts(1:idxSub(i)-1), {Name}], '/');
    % Rename the path, but only if they're actually different
    if ~strcmpi(thisPath, newPath)
        % Command window
        fprintf('>> BIDS: renaming directory %s to %s\n', thisPath, newPath)
        % ---------------------------------------------------------
        % Create command
        if ispc
            cmd = ['Rename "', strrep(thisPath, '/', filesep), '" ', Name];
        else
            cmd = ['mv "', thisPath, '" "', newPath, '"'];
        end
        % ---------------------------------------------------------
        % Now run the command
        [status, cmdout] = system(cmd);
        % Check if the command has been executed correctly
        if status ~= 0
            sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when renaming a directory.', cmdout}, 'Error', ...
                'Options', {'Ok'},...
                'DefaultOption', 'Ok', ...
                'Icon', 'error'); %#ok<NASGU>
            hasError = true;
            return
        end % All is well, we can continue
    end
    % ---------------------------------------------------------
    % Update the path parts now that we have made the change on disk
    PathParts{idxSub(i)} = Name;
    % Continue with the next 'sub-*' directory
end
% ---------------------------------------------------------
% Construct the new path
NewPath = strjoin(PathParts, '/');

end