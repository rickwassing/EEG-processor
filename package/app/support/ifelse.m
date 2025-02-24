% IFELSE
% Inline use of an if-else statement. Returns 'a' if b is True, or b
% otherwise.
%
% Usage:
%   >> out = ifelse(bool, a, b);
%
% Inputs:
%   bool - [boolean] (1, 1)
%   a - [any]
%   b - [any]
%
% Outputs:
%   out - [any] a (if bool is True) or b otherwise

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-21, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function out = ifelse(bool, a, b)

if ~islogical(bool) || ~isscalar(bool)
    error('Input "bool" must be a logical scalar.');
end

if bool
    out = a;
else
    out = b;
end

end