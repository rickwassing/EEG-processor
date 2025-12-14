% SORT_CHANGED
% Updates the sorting preference by the user.
%
% Usage:
%   >> sort_changed(payload)
%
% Inputs:
%   payload - [struct] Structure containing the field 'path'
%
% Outputs:
%    new field in store, ds:currentSortField

% Authors:
%   Sapir Bar, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-23, Sapir Bar

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function sort_changed(payload) 
try
    % Short hand to the store
    store = app_store.getInstance();
    % Update the path
    store.ds.currentSortField = payload.SortResponse;
catch ME
    printerrormessage(ME, sprintf('The error occurred during in %s.', mfilename('class')))
end

end

              