% ASCOLUMN
% Forces a vector to be a column vector
%
% Usage:
%   >> v = ascolumn(v)
%
% Inputs:
%   v - [numeric | cell] (1, n) vector
%
% Outputs:
%   v - [numeric | cell] (n, 1) vector

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function v = ascolumn(v)

% Validate input type
if ~isnumeric(v) && ~iscell(v)
    error('ascolumn:InvalidInput', 'Input must be a numeric or cell vector.');
end

% Validate input shape
if ~isvector(v)
    error('ascolumn:InvalidShape', 'Input must be a vector.');
end

% Convert row vector to column vector
if isrow(v)
    v = v';
end

end