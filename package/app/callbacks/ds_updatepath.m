% DS_UPDATEPATH
% Updates the path to the dataset
%
% Usage:
%   >> ds_updatepath(payload)
%
% Inputs:
%   payload - [struct] Structure containing the field 'path'
%
% Outputs:
%   new fields in store,ds:files_all,subjects_all,JSON

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%   Sapir Bar, Woolcock Institute of Medical Research, Sydney, Australia

% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function ds_updatepath(payload) 
try
    % Short hand to the store
    store = app_store.getInstance();
    % Update the path
    store.ds.updatePath(payload.path);
    store.db.insert('app', 'recent', {payload.path}, 'makeunique', true, 'croplimit', 15);

    if exist([store.ds.path, '/rawdata/dataset_description.json'], 'file') ~= 0
        store.ds.JSON = json2struct([store.ds.path, '/rawdata/dataset_description.json']);    
    else
        %creating the state for json file
        NewState = DefaultState(store.ds.path);
        store.ds.JSON = NewState.JSON;
    end

    store.ds.files_all= payload.files_all;
    store.ds.subjects_all= payload.subjects_all;
    
catch ME
    printerrormessage(ME, sprintf('The error occurred during in %s.', mfilename('class')))
end


end
