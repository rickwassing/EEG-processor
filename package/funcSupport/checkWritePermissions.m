function [app, Permissions] = checkWritePermissions(app, path)
% Force appropriate slashes
path = strrep(path, '/', filesep);
% Assume everything is fine
Permissions = true;
% Try to write a file
try
    fid = fopen([path, '/check-permissions.txt'], 'w');
    if fid == -1
        Permissions = false;
    end
    fprintf(fid, matlab_ipsum('Paragraphs', 100, 'Sentences', 15)); % try to save a file
    fclose(fid);
    delete([path, '/check-permissions.txt']);
    % try to create a directory
    [status, cmdout] = system(['mkdir "', path, filesep, 'test"']);
    if status ~= 0
        error(cmdout);
    end
    % try to rename directory
    if ispc
        cmd = ['Rename "', path, filesep, 'test" testing'];
    else
        cmd = ['mv "', path, filesep, 'test" "', path, filesep, 'testing"'];
    end
    [status, cmdout] = system(cmd);
    if status ~= 0
        error(cmdout)
    end
    % try to delete dir
    if ispc
        cmd =  ['rd /s /q "', path, filesep, 'testing"'];
    else
        cmd =  ['rm -rf "', path, filesep, 'testing"'];
    end
    [status, cmdout] = system(cmd);
    if status ~= 0
        error(cmdout)
    end
catch ME
    printME(ME)
    Permissions = false;
end

end
