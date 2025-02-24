% JSON2STRUCT
% Reads a JSON file and returns a MATLAB structure.
%
% Usage:
%   >> data = readJSON('data.json');
%
% Inputs:
%   filename - [string | char array] the JSON file path
%
% Outputs: 
%   data - [struct] MATLAB structure containing the parsed JSON data

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2025-02-20, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function data = json2struct(filename)

% Check if filename is provided
if nargin < 1 || isempty(filename)
    error('Filename must be specified.');
end

% Ensure file exists
if ~isfile(filename)
    error('File not found: %s', filename);
end

% Try to read the JSON file
try
    fid = fopen(filename, 'r'); % Open the file for reading
    rawText = fread(fid, '*char')'; % Read file as a character array
    fclose(fid); % Close the file
    % Parse JSON into a structure
    data = jsondecode(rawText);
catch ME
    data = [];
    printerrormessage(ME)
end

end