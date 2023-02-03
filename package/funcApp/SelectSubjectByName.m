function [SubjectList, ids] = SelectSubjectByName(app, Name)
% ---------------------------------------------------------
idx = cellfun(@(id) strcmpi(app.State.Subjects.Entities.(id).Name, Name), app.State.Subjects.ids);
ids = app.State.Subjects.ids(idx);
SubjectList = cellfun(@(id) app.State.Subjects.Entities.(id), ids, ...
    'UniformOutput', false);
end