function defJSON = DefaultdefJSON(Path, varargin)

defJSON = struct();
[~, defJSON.Name] = fileparts(Path);

defJSON.JSON.Name = defJSON.Name;
defJSON.JSON.BIDSVersion = '1.8.0';
defJSON.JSON.DatasetType = 'raw';
defJSON.JSON.GeneratedBy.Name = 'Woolcock Institute of Medical Research, Sydney, Australia';
defJSON.JSON.GeneratedBy.Version = '11/02/2022';
defJSON.JSON.GeneratedBy.Description = 'Preprocessing and analysis pipeline for high-density EEG (sleep) recordings in healthy controls and affected populations.';
defJSON.JSON.License = 'Public Domain';
defJSON.JSON.Authors = {''};
defJSON.JSON.Acknowledgements = '';
defJSON.JSON.HowToAcknowledge = '';
defJSON.JSON.Funding = {''};
defJSON.JSON.EthicsApprovals = {''};
defJSON.JSON.ReferencesAndLinks = {''};
defJSON.JSON.DatasetDOI = '10.xxxx';
% ---------------------------------------------------------
defJSON.Subjects = table();
defJSON.Files = table();
% ---------------------------------------------------------


end