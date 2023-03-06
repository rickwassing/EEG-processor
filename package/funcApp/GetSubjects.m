function Subjects = GetSubjects(app)
% ---------------------------------------------------------
% Read all the directory names starting with "sub-" in the raw and any
% other derivative's directory
Dirs = dir([app.State.Protocol.Path, '/rawdata/sub-*']);
DerivativeDirs = dir([app.State.Protocol.Path, '/derivatives/EEG-*']);
for i = 1:length(DerivativeDirs)
    if i == 1
        tmp = dir([app.State.Protocol.Path, '/derivatives/', DerivativeDirs(i).name,'/sub-*']);
    else
        tmp = [tmp; dir([app.State.Protocol.Path, '/derivatives/', DerivativeDirs(i).name,'/sub-*'])]; %#ok<AGROW> 
    end
end
Dirs = [Dirs; tmp];
% Filter out any non-directory
Dirs = Dirs([Dirs.isdir] == 1);
% Get all the unique directory names
[~, idx] = unique({Dirs.name});
% ---------------------------------------------------------
% For each unique subject, add it to the structure
randomSeeds = randperm(length(idx),length(idx));
Subjects = table(...
    'Size', [length(idx), 5], ...
    'VariableNames', {'Id', 'Name', 'FileIds', 'Status', 'PrevState'}, ...
    'VariableTypes', {'cellstr', 'cellstr', 'cell', 'cellstr', 'cell'});
for i = 1:length(idx)
    id = ['X', datestr(now, 'HHMMSSFFF'), num2str(randomSeeds(i))];
    Subjects.Id{i} = id;
    Subjects.Name{i} = Dirs(idx(i)).name;
    Subjects.Status{i} = 'idle';
end
% ---------------------------------------------------------
% Command Window
fprintf('>> BIDS: %i subjects loaded.\n', length(idx))
end
