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
%   none

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function auth_changed(name) 
    try
        % Short hand to the store
        store = app_store.getInstance();
        % Update the username
        if ~isempty(name)
        % Store user name
            store.auth.username = name;
        else
            store.auth.username = ''
        end

    catch ME
        printerrormessage(ME, sprintf('The error occurred during in %s.', mfilename('class')))
    end
end