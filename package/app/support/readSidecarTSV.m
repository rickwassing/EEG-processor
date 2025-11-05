function T = readSidecarTSV(fname, type)
% ---------------------------------------------------------
% Initialize table
T = table();
% Specify the format
switch lower(type)
    case 'electrodes'
        formatSpec = {'%s', '%f', '%f', '%f'};
        variableNames = {'name', 'x', 'y', 'z'};
    case 'channels'
        formatSpec = {'%s', '%s', '%s', '%u', '%s', '%s'};
        variableNames = {'name', 'type', 'units', 'sampling_frequency', 'reference', 'status'};
    case 'events'
        formatSpec = {'%f', '%f', '%s'};
        variableNames = {'onset', 'duration', 'trial_type'};
end
% ---------------------------------------------------------
% Read file using text-scan, is way faster
try
    fid = fopen(fname, 'r');
    % If it is a channels file, check if the 'description' column is in there
    if strcmpi(type, 'channels') 
        numCols = sum(fgets(fid) == 9)+1;
        if numCols == 7
            formatSpec = [formatSpec, {'%s'}];
            variableNames = [variableNames, {'description'}];
        end
        fclose(fid);
        fid = fopen(fname, 'r');
    else
        numCols = length(variableNames);
    end
    tmp = textscan(fid, deblank(repmat('%s ', 1, numCols)), 'headerLines', 1, 'Delimiter', '\t');
    fclose(fid);
catch ME
    printME(ME);
    fclose(fid);
    return
end
% ---------------------------------------------------------
% Construct the table
for v = 1:length(variableNames)
    switch formatSpec{v}
        case '%s'
            val = tmp{v};
        case '%f'
            val = str2double(tmp{v});
        case '%u'
            val = str2double(tmp{v});
    end
    T.(variableNames{v}) = val;
end
end