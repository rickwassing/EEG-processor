function [FileList, ids] = SelectFileById(app, FileIds)
% ---------------------------------------------------------
idx = matches(app.State.Files.Id, FileIds);
FileList = app.State.Files(idx, :);
ids = app.State.Files.Id(idx);
end