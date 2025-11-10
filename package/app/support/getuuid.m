% GETUUID
% Generares a unique identifier
%
% Usage:
%   >> id = getuuid()
%
% Inputs:
%   none
%
% Outputs:
%   id - [char array] unique id

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function [id] = getuuid()
id = ['x', strrep(char(matlab.lang.internal.uuid()), '-', '_')];
end