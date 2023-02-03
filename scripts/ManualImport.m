%%
% KEY-VALS
Import.Subject = 'p2s66';
Import.Session = '2';
Import.Task = 'psg';
Import.Run = 1;
% INPUT DATA FILE
Import.FileType = 'EEG';
Import.DataFile.Type = 'COMPU257'; % choose from 'MFF', 'COMPU257', 'GRAEL'
Import.DataFile.Path = '/Volumes/sleep/Sleep/2. STAFF/Rick/Z-Drugs for Analysis/Z-Drugs_EDF_30NOV2022/KDT EDF/XX_ZDRUGS_KDT_PM.edf';
% CHANNEL LOCATIONS
Import.Channels.Type = 'Geoscan'; % Choose from 'Geoscan', 'GSN-HydroCel-257', 'Compumedics-257'
Import.Channels.Path = '/Volumes/sleep/Sleep/2. STAFF/Rick/Z-Drugs for Analysis/check-me.txt';
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
Import.SaveAs.Path = ['./check-me'];
% --------------------------------------------------
% RUN IMPORT
[~, fname] = fileparts(Import.DataFile.Path);
fprintf('>> ==============================\n')
fprintf('>> BIDS: IMPORTING ''%s''\n', fname)
[~, ~, Warnings] = ImportFile(Import);
