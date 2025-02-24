% FILTERPATHS
% Filters file paths based on the operating system.
%
% Usage:
%   >> filtered = filterpaths(recents)
%
% Inputs:
%   recents - [cell] Cell array of file paths
%
% Outputs:
%   filtered - [cell] Cell array containing only valid paths for the current OS

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function paths = filterpaths(paths)

% Ensure input is a cell array of strings
if ~iscell(paths) || ~all(cellfun(@ischar, paths))
    error('Input must be a cell array of character vectors.');
end

% Determine OS-specific path filter
if ispc
    % Windows paths typically start with a drive letter (e.g., 'C:\') or a network path ('\\')
    validPaths = @(p) startsWith(p, {...
        'A:\', 'B:\', 'C:\', 'D:\', 'E:\', ...
        'F:\', 'G:\', 'H:\', 'I:\', 'J:\', ...
        'K:\', 'L:\', 'M:\', 'N:\', 'O:\', ...
        'P:\', 'Q:\', 'R:\', 'S:\', 'T:\', ...
        'U:\', 'V:\', 'W:\', 'X:\', 'Y:\', ...
        'Z:\', '\\'}, 'IgnoreCase', true);
elseif ismac || isunix
    % macOS and Linux paths start with '/'
    validPaths = @(p) startsWith(p, '/');
else
    error('Unsupported operating system.');
end

existingPaths = @(p) exist(p, 'dir') ~= 0;

% Filter paths
paths = paths(cellfun(validPaths, paths));
paths = paths(cellfun(existingPaths, paths));

end