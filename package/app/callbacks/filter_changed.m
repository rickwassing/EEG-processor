% FILTER_UPDATED
% Updates the filters for showing the relevant files only
%
% Usage:
%   >> filter_changed(payload)
%
% Inputs:
%   payload - [struct] Structure containing the field 'path'
%
% Outputs:
%   new field in store, ds:currentFilter

% Authors:
%   Sapir Bar Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-22, Sapir Bar

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function filter_changed(payload) 
try
    % Short hand to the store
    store = app_store.getInstance();
    % Update the filter
    store.ds.currentFilter=payload;

catch ME
    printerrormessage(ME, sprintf('The error occurred during in %s.', mfilename('class')))
end

end