function [FileList, ids, idx] = SelectFilesByKeyValue(app, Key, Value, varargin)
% You must specify at least one key value pair by which you want to select
% files, but you can specify more if you like
% ---------------------------------------------------------
idx = cellfun(@(s) handleSelect(s, Key, Value), app.State.Files.KeyVals);
for i = 1:2:length(varargin)
    idx = idx & cellfun(@(s) handleSelect(s, varargin{i}, varargin{i+1}), app.State.Files.KeyVals);
end
idx = find(idx);
ids = app.State.Files.Id(idx);
FileList = app.State.Files(idx, :);

    function bool = handleSelect(KeyVals, Key, Val)
        if isfield(KeyVals, Key)
            bool = strcmpi(KeyVals.(Key), Val);
        else
            bool = false;
        end
    end
end