function [SubjectList, ids, idx] = SelectSubjectByName(app, Name)
% ---------------------------------------------------------
idx = find(matches(app.State.Subjects.Name, Name));
ids = app.State.Subjects.Id(idx);
SubjectList = app.State.Subjects(idx, :);
end