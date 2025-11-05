% LOGGING
% Logs changes to the application state
%
% Usage:
%   >> out = logging(slice, currentState, newState);
%
% Inputs:
%   auth - [struct] Authentication information
%   action - [char array] Action descriptor ('view', 'create', 'update', 'delete').
%   slice - [char array] the slice of the state that the action is applied to.
%   varargin - [cell array] key-value pairs of additional properties e.g.,
%       currentState - [struct] current key values of the slice's state.
%       newState - [struct] new key values of the slice's state.
%
% Outputs:
%   out - [bool] (1, 1) determinant whether the update should pass or not
%   msg - [char array] optional message to explain why the state was not
%       updated.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-21, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function [b, msg] = logging(auth, action, slice, varargin)
% Init output
b = true;
msg = '';
% parse varagin
props = parsevarargin(varargin);
% Print the state changes to the command window
fprintf('[%s] %s %s %s.\n', char(datetime(), 'HH:mm:ss'), auth.username, action, slice)
end