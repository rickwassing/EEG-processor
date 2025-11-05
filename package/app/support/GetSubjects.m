function Subjects = GetSubjects(store)
% ---------------------------------------------------------
% Read all the directory names starting with "sub-" in the raw and any
% other derivative's directory
Dirs = dir([store.ds.path, '/rawdata/sub-*']);
DerivativeDirs = dir([store.ds.path, '/derivatives/EEG-*']);
for i = 1:length(DerivativeDirs)
    tmp = dir([store.ds.path, '/derivatives/', DerivativeDirs(i).name, '/sub-*']);
    Dirs = [Dirs; tmp]; %#ok<AGROW>
end
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