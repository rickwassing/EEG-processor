% APP_CALLBACK
% Wrapper function to handle all callbacks and emit event broadcasts
%
% Usage:
%   >> app_callback(source, event, payload, eventnames);
%
% Inputs:
%   source - [uielement] Some UI element that triggered the event
%   event - [eventdata] The event data associated with the event
%   payload - [struct] Structure containing the payload to change the state
%   eventlabels - [cell] Cell array of the event labels to broadcast
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

function app_callback(source, event, callbackfx, payload, eventlabels) %#ok<INUSD>

try
    if nargin == 5
        % Get the handle to the store
        store = app_store.getInstance();
    else
        eventlabels = [];
    end
    % Execute the callback function
    callbackfx(payload)
    % Broadcast the event labels so other components can update
    for i = 1:length(eventlabels)
        notify(store, eventlabels{i}, event);
    end
catch ME
    printerrormessage(ME, sprintf('The error occurred during in %s.', mfilename('class')))
end

end