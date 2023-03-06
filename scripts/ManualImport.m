%%
% KEY-VALS
Import.Subject = '19cw';
Import.Session = '1';
Import.Task = 'psg';
Import.Run = 2;
% INPUT DATA FILE
Import.FileType = 'EEG';
Import.DataFile.Type = 'MFF'; % choose from 'MFF', 'COMPU257', 'GRAEL'
Import.DataFile.Path = '/Volumes/research-data/PRJ-CFSNRS/sourcedata/sub-19cw/psg/sub-19cw_ses-1_task-psg_run-2_eeg_20230209_005315.mff';
% CHANNEL LOCATIONS
Import.Channels.Type = 'Geoscan'; % Choose from 'Geoscan', 'GSN-HydroCel-257', 'Compumedics-257'
Import.Channels.Path = '/Volumes/research-data/PRJ-CFSNRS/sourcedata/sub-19cw/geoscan/nrs_sub_19cw_geoscan_20230208-192919.txt';
% EVENTS
Import.Events.Do = false;
Import.Events.HypnoPath = '';
Import.Events.EventsPath = '';
Import.Events.WonambiXMLPath = '';
% PROCESSING
Import.Processing.DoResample = false;
Import.Processing.DoFilter = true;
Import.Processing.FilterSettings.DoBandpass = true;
Import.Processing.FilterSettings.DoNotch = true;
Import.Processing.FilterSettings.Highpass = 0.1;
Import.Processing.FilterSettings.Lowpass = 60;
Import.Processing.FilterSettings.Notch = 50;
Import.Processing.FilterSettings.WindowType = 'Hamming';
Import.Processing.FilterSettings.TransitionBW = 0.2;
Import.Processing.FilterSettings.FilterOrder = 8250;
Import.Processing.DoSpectrogram = false;
Import.Processing.DoICA = false;
% SAVE AS
Import.SaveAs.Type = 256;
Import.SaveAs.Path = '/Volumes/research-data/PRJ-CFSNRS/sourcedata/sub-19cw/psg/sub-19cw_ses-1_task-psg_run-2_eeg.set';
% --------------------------------------------------
% RUN IMPORT
[~, fname] = fileparts(Import.DataFile.Path);
fprintf('>> ==============================\n')
fprintf('>> BIDS: IMPORTING ''%s''\n', fname)
[~, ~, Warnings] = ImportFile(Import);
