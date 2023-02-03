function CreateNewDirectory(Path)

% Replace forward slashes with the OS default
Path = strrep(Path, '/', filesep);
% Log to command window
fprintf('>> BIDS: Creating new path "%s".\n', Path)
% Run command
if ispc
    [status, cmdout] = system(['mkdir "', Path, '"']);
else
    % ---------------------------------------------------------
    % This section is to deal with the read-only file system on Mac
    % Catalina and later. We can only use 'mkdir' on the RDS when we change
    % the current directory to within the RDS i.e., we cannot provide the
    % full path. This would result in a 'read-only' error. 
    % Get current path so we can 'cd' back to where we were
    currentDirectory = pwd();
    % Find the root dir index
    rootDirIdx = regexp(Path, 'rawdata|derivatives', 'once');
    % If the index had been found...
    if ~isempty(rootDirIdx)
        % ... extract the root dir
        rootDirectory = Path(1:rootDirIdx-2);
        % Check if the root dir exists
        if exist(rootDirectory, 'dir')
            % Change directory to the root dir
            try
                cd(rootDirectory)
                % Replace the rootdir with a '.' in the 'Path' variable
                Path = strrep(Path, rootDirectory, '.');
            catch
                fprintf('Could not change directory to parent path. Will try to create new directory anyway. This may fail on the RDS.\n')
            end
        end
    end
    % ---------------------------------------------------------
    % Create the directory
    [status, cmdout] = system(['mkdir -p "', Path, '"']);
    % CD back to where we were
    cd(currentDirectory)
end
% Check output of the command
if status ~= 0 && ~regexpIdx(cmdout, 'already exists')
    error('An unexpected error occurred when creating a new directory:\n%s.', cmdout)
elseif regexpIdx(cmdout, 'already exists')
    warning('No need for creating a new directory, it already exists:\n%s.', cmdout)
end

end
