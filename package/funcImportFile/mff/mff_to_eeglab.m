% mff_to_eeglab() - load an Netstation MFF EEG dataset.
%
% Usage:
%   >> EEG = mff_to_eeglab(fileName); % loads .MFF dataset and saves to .SET/.FDT EEGLAB file with the same name and location
%   >> EEG = mff_to_eeglab(fileName, 'Name', 'Value'); % Specify which additional files should be loaded or where to save the .SET/.FDT EEGLAB file, see below.
%
% Optional inputs:
%   'scoreFile'   - [string] path to a text file containing the scored sleep stages (Compumedics).
%                   The sleep stages are added as events to the EEG structure.
%   'eventFile'   - [string] path to a text file containing the scored events (Compumedics).
%                   The events are added as events to the EEG structure.
%   'geoscanFile' - [string] path to a tabular file containing the scanned locations of the channels.
%                   The channel locations are added in the '.chanloc' structure in the EEG structure.
%                   If not provided, this function will load the channel locations in 'GSN-HydroCel-257.sfp'.
%   'saveFile'    - [string] path to the file where to save the .SET/.FDT EEGLAB file.
%   'eegChannels' - [cell array] indicating the names of the channels to load, e.g. 
%                   {'E1', 'E2', ... , 'Cz'}. Note that channel 257 is labelled  'Cz'.
%   'loadPib'     - [string] value 'yes' or 'no', to indicate whether the PIB data should be loaded.
%
% Output
%   'EEG' - EEG dataset structure or array of structures
%
% Author: 
%   Rick Wassing, Woolcock Institute Of Medical Research, 2020
%   rick.wassing@sydndey.edu.au
%
% Copyright (C) 2020 Rick Wassing, Woolcock Institute Of Medical Research, rick.wassing@sydndey.edu.au
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function EEG = mff_to_eeglab(fileName, varargin)

% INITIALIZE
% -------------------------------------------------------------------------

% The varargin parser
p = inputParser;
addParameter(p, 'scoreFile', [], ...
    @(x) validateattributes(x, {'char'}, {'scalartext'}) ...
);
addParameter(p, 'eventFile', [], ...
    @(x) validateattributes(x, {'char'}, {'scalartext'}) ...
);
addParameter(p, 'geoscanFile', 'auto', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
addParameter(p, 'saveName', 'auto', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
addParameter(p, 'eegChannels', {'all'}, ...
    @(x) validateattributes(x, {'cell'}, {'vector'}) ...
);
addParameter(p, 'loadPib', 'yes', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
% Parse the variable arguments
parse(p,varargin{:});
p = p.Results;
% If 'saveName' is not provided, then use the same name as the MFF file.
if strcmpi(p.saveName, 'auto')
    [savePath, saveName] = fileparts(fileName);
    p.saveName = fullfile(savePath, saveName);
end

% Check if files exist
if  exist(fileName) == 0; error('.MFF file not found. (%s)', fileName); end
if ~isempty(p.scoreFile) && exist(p.scoreFile, 'file') == 0; error('Score file not found. (%s)', p.scoreFile); end
if ~isempty(p.eventFile) && exist(p.eventFile, 'file') == 0; error('Event file not found. (%s)', p.eventFile); end
if ~strcmp(p.geoscanFile, 'auto') && exist(p.geoscanFile, 'file') == 0; error('Geoscan file not found. (%s)', p.geoscanFile); end
if  strcmp(p.geoscanFile, 'auto') && exist(which('GSN-HydroCel-257.sfp'), 'file') == 0; error('GSN-HydroCel-257.sfp file not found.'); end

% get the mff meta data for all the data information
disp('Importing MFF meta data.');
mffData = mff_import_meta_data(fileName);

% CREATE NEW EEGLAB STRUCTURE AND SAVE META DATA
% -------------------------------------------------------------------------
disp('Creating empty EEG structure.');
% initialise EEG structure
EEG = mff_newset(mffData);

% IMPORTING EEG CHANNEL LOCATIONS
% -------------------------------------------------------------------------
disp('Importing EEG channel locations.');
if strcmp(p.geoscanFile, 'auto')
    EEG = import_chanlocs(EEG, which('GSN-HydroCel-257.sfp'));
else
    EEG = geoscan_to_chanlocs(EEG, p.geoscanFile);
end

% Set the reference channel of all channels to Cz
EEG = pop_chanedit(EEG, 'setref', {'1:257', 'Cz'});

% ONLY KEEP THOSE EEG CHANNELS THE USE SPECIFIED TO LOAD
% -------------------------------------------------------------------------
if all(~strcmpi(p.eegChannels, 'all'))
    % Find indices of user-specified EEG channels, plus Cz.
    % We MUST load Cz as it is the reference channel
    idx = ismember({EEG.chanlocs.labels}, [p.eegChannels, {'Cz'}]);
    % Throw an error if not all specified EEG channels could be found
    if sum(idx) ~= length(p.eegChannels)
        error('Could not find all specified EEG channels in the data.')
    end
    % Reduce EEG.chanlocs and update the number of channels
    EEG.chanlocs = EEG.chanlocs(idx);
    EEG.nbchan = length(EEG.chanlocs);
end

% LOAD THE EEG DATA
% -------------------------------------------------------------------------
disp('Loading the EEG data.');
EEG = mff_import_eeg_data(EEG, mffData);

% CALCULATE EOG CHANNELS
% -------------------------------------------------------------------------
% Check if the required channels are available, otherwise skip this step
if all(ismember({'E1', 'E18', 'E238', 'E252'}, {EEG.chanlocs.labels}))
    disp('Calculating EOG channels.');
    EEG = mff_calc_eog(EEG);
end

if strcmpi(p.loadPib, 'yes')
    % LOAD ALL PHYSIOLOGY DATA
    % -------------------------------------------------------------------------
    disp('Loading the Physiology data.');
    EEG = mff_import_pib_data(EEG, mffData);
    % IMPORTING PIB CHANNEL LOCATIONS
    disp('Importing PIB channel locations.');
    EEG = mff_import_piblocs(EEG, fileName);
end

% Store the original channel locations in case we delete any channels
EEG.urchanlocs = EEG.chanlocs;

% LOAD ALL EVENTS FROM THE MFF FILE
% -------------------------------------------------------------------------
disp('Importing events from MFF dataset.');
EEG = mff_import_events(EEG, fileName);

% LOAD THE HYPNOGRAM AND SLEEP EVENTS
% -------------------------------------------------------------------------
if ~isempty(p.scoreFile)
    disp('Importing events from scored hypnogram.');
    EEG = compumed_import_sleep_scores(EEG, p.scoreFile);
end
if ~isempty(p.eventFile)
    disp('Importing events from scored events.');
    EEG = compumed_import_sleep_events(EEG, p.eventFile);
end

% CHECK THE DATA AND EVENT CONSISTENCY
% -------------------------------------------------------------------------

% check the size of the EEG data and make sure its consistent with nbchan and chanlocs
if size(EEG.data, 1) ~= EEG.nbchan
    error('The number of rows in the matrix ''EEG.data'' is not equal to the value of ''EEG.nbchan''.')
end
if size(EEG.data, 1) ~= length(EEG.chanlocs)
    error('The number of rows in the matrix ''EEG.data'' is not equal to the length of ''EEG.chanlocs''.')
end
if length(EEG.chanlocs) ~= EEG.nbchan
    error('The length of ''EEG.chanlocs'' is not equal to the value of ''EEG.nbchan''.')
end

% check the eeg for consistency
EEG = eeg_checkset(EEG, 'eventconsistency');

% Store the original events in case we modify any of the events
EEG.urevent = EEG.event;

% SAVE THE DATASET
% -------------------------------------------------------------------------
disp('Saving EEGLAB dataset.');
[EEG.filepath, EEG.filename] = fileparts(p.saveName);
EEG.setname = EEG.filename;
EEG.filename = [EEG.filename, '.set'];
if isempty(EEG.filepath); EEG.filepath = pwd; end
EEG = pop_saveset(EEG, fullfile(EEG.filepath, EEG.filename), 'version', '7.3');

end
