function [FileList, ids] = SelectFilesByKeyValue(app, Key, Value, varargin)
% You must specify at least one key value pair by which you want to select
% files, but you can specify more if you like
% ---------------------------------------------------------
idx = cellfun(@(id) strcmpi(app.State.Files.Entities.(id).KeyVals.(Key), Value), app.State.Files.ids);
for i = 1:2:length(varargin)
    idx = idx & cellfun(@(id) handleSelect(app.State.Files.Entities.(id).KeyVals, varargin{i}, varargin{i+1}), app.State.Files.ids);
end
ids = app.State.Files.ids(idx);
FileList = cellfun(@(id) app.State.Files.Entities.(id), ids, ...
    'UniformOutput', false);

    function bool = handleSelect(KeyVals, Key, Val)
        if isfield(KeyVals, Key)
            bool = strcmpi(KeyVals.(Key), Val);
        else
            bool = false;
        end
    end
end