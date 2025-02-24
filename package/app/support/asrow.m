% ASROW
% Forces a vector to be a row vector.
%
% Usage:
%   >> v = asrow(v)
%
% Inputs:
%   v - [numeric | cell] (n, 1) vector
%
% Outputs:
%   v - [numeric | cell] (1, n) vector

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0.

function v = asrow(v)

% Validate input type
if ~isnumeric(v) && ~iscell(v)
    error('asrow:InvalidInput', 'Input must be a numeric or cell vector.');
end

% Validate input shape
if ~isvector(v)
    error('asrow:InvalidShape', 'Input must be a vector.');
end

% Convert column vector to row vector
if iscolumn(v)
    v = v'; % Transpose to row vector
end
end