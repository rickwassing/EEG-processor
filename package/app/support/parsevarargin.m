% PARSEVARARGIN
% Takes in a cell array of name-value pairs and returns this data in a
% structure
%
% Usage:
%   >> s = parsevarargin(args);
%
% Inputs:
%   args - [cell array] (1, 2*n) Cell array of 'n' key-value pairs
%
% Outputs: 
%   s - [struct] MATLAB structure containing the parsed key-value pairs

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2025-02-20, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function s = parsevarargin(args)

if mod(length(args), 2) == 1
    error('Input must have an even length')
end

s = struct();
for i = 1:2:length(args)
    s.(lower(args{i})) = args{i+1};
end

end