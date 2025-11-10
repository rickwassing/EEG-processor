% STRUCT2JSON
% Converts a MATLAB structure into a JSON file.
%
% Usage:
%   >> struct2json(data, 'output.json');
%
% Inputs:
%   data - [struct] MATLAB structure to be converted to JSON
%   filename - [string | char array] the output JSON file path
%
% Outputs: 
%   none
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

function struct2json(data, filename)

% Check if data is provided
if nargin < 1 || isempty(data)
    error('Data must be provided.');
end

% Check if filename is provided
if nargin < 2 || isempty(filename)
    error('Filename must be specified.');
end

% Ensure filename is a string
if ~ischar(filename) && ~isstring(filename)
    error('Filename must be a string or char array.');
end

% Try to encode the MATLAB structure into JSON
try
    % Convert structure to JSON string
    jsonData = jsonencode(data, 'PrettyPrint', true);
    
    % Open the file for writing (create new file or overwrite if exists)
    fid = fopen(filename, 'w');
    if fid == -1
        error('Failed to open the file: %s', filename);
    end
    % Write the JSON string to the file
    fwrite(fid, jsonData, 'char');
    fclose(fid); % Close the file
    
catch ME
    printerrormessage(ME);
end

end