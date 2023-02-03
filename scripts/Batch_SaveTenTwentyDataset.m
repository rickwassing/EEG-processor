%%% =======================================================================
%%% This script only works with BIDS-formatted data. It allows you to
%%% convert multiple high-density .SET/FDT files to 12-channel EDF
%%% including an EOG channel.
%%% - First confirm that the initiation section contains the correct paths
%%% - Then adapt the absolute path using wildcards '*' to search for all
%%%   the .SET files you want to convert. It is best to select 'inspected'
%%%   data from the 'derivatives' directory. This way, any bad channels
%%%   will be interpolated before selecting them for the EDF.
%%% - Specify the root-directory where to save the output.
%%% =======================================================================
%%% INITIATION
clc; clear; % Clear the Command Window and Workspace
% Add the EEG Processor to the path
addpath(genpath('S:/Sleep/SleepSoftware/EEG_Processor/latest'))
% Add EEGLAB to the path
addpath('S:/Sleep/SleepSoftware/eeglab/latest'); eeglab; close all
%%% =======================================================================
%%% PATHS TO .SET FILES
% Create a structure containing all .SET/FDT files to convert
FILES = dir('Y:\PRJ-HdEEG_Schiz\derivatives\EEG-inspect\sub-09kk2\sub-09kk2_ses-2_task-psg_run-1_desc-inspect_eeg.set');
FILES = [FILES; dir('Y:\PRJ-HdEEG_Schiz\derivatives\EEG-inspect\sub-15dk\sub-15dk_ses-1_task-psg_run-1_desc-inspect_eeg.set')];
FILES = [FILES; dir('Y:\PRJ-HdEEG_Schiz\derivatives\EEG-inspect\sub-16mc\sub-16mc_ses-1_task-psg_run-1_desc-inspect_eeg.set')];
FILES = [FILES; dir('Y:\PRJ-HdEEG_Schiz\derivatives\EEG-inspect\sub-17am\sub-17am_ses-1_task-psg_run-1_desc-inspect_eeg.set')];
% Specify the output root directory
OUTPUT_ROOT_DIR = 'Y:\PRJ-HdEEG_Schiz\derivatives\EEG-convert1020';
%%% =======================================================================
%%% THAT'S IT, THE CODE BELOW WILL TAKE CARE OF THE REST
%%% =======================================================================
% Show the user the list of files
if isempty(FILES)
    disp('>> BIDS: No files found that match the search string.')
    disp('>> BIDS: Adapt the input argument for the function ''dir'' on line 22 and try again.')
else
    disp('>> BIDS: Batch converting the following files:')
    for i = 1:length(FILES)
        fprintf('>> BIDS: (%i) %s\n', i, FILES(i).name)
    end
    % % Loop over all the files
    for i = 1:length(FILES)
        try
            % Load high density dataset
            EEG = LoadDataset([FILES(i).folder, filesep, FILES(i).name], 'all');
            % Change the filepath to the output root directory
            EEG.filepath = [strrep(OUTPUT_ROOT_DIR, '\', '/'), '/sub-', EEG.subject];
            % Get keys and values to change the filename
            KeysValues = filename2struct(EEG.setname);
            Keys = fieldnames(KeysValues); Keys(end) = [];
            Values = struct2cell(KeysValues); Values(end) = [];
            % Change the 'desc' key value
            idx = strcmpi(Keys, 'desc');
            Values{idx} = 'convert1020';
            BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
            EEG.setname = strjoin([BaseFilename; {'eeg'}], '');
            Settings.Path = [EEG.filepath, '/', EEG.setname];
            % Call the conversion function
            [EEG, ~, Warnings] = SaveTenTwentyDataset(EEG, Settings, {});
            % Print warnings
            for j = 1:length(Warnings)
                disp(Warnings{j})
            end
        catch ME
            printME(ME)
        end
    end
end
