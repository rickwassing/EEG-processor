function [FileList, ids] = SelectFileById(app, FileIds)
% ---------------------------------------------------------
idx = ismember(app.State.Files.ids, FileIds);
ids = app.State.Files.ids(idx);
FileList = cellfun(@(id) app.State.Files.Entities.(id), ids, ...
    'UniformOutput', false);
end