function Subjects = GetSubjects(app)
% ---------------------------------------------------------
% Initialize
Subjects = struct();
Subjects.ids = {};
Subjects.Entities = {};
% ---------------------------------------------------------
% Read all the directory names starting with "sub-" in the raw and any
% other derivative's directory
Dirs = dir([app.State.Protocol.Path, '/rawdata/sub-*']);
tmp = dir([app.State.Protocol.Path, '/derivatives/*/sub-*']);
Dirs = [Dirs; tmp];
% Filter out any non-directory
Dirs = Dirs([Dirs.isdir] == 1);
% Get all the unique directory names
[~, idx] = unique({Dirs.name});
% ---------------------------------------------------------
% For each unique subject, add it to the structure
randomSeeds = randperm(length(idx),length(idx));
for i = 1:length(idx)
    id = ['X', datestr(now, 'HHMMSSFFF'), num2str(randomSeeds(i))];
    Subjects.ids = [Subjects.ids; {id}];
    Subjects.Entities.(id).Id = id;
    Subjects.Entities.(id).Name = Dirs(idx(i)).name;
    Subjects.Entities.(id).FileIds = cell(0);
    Subjects.Entities.(id).Status = 'idle';
end
% ---------------------------------------------------------
% Command Window
fprintf('>> BIDS: %i subjects loaded.\n', length(idx))
end
