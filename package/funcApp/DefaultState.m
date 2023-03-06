function State = DefaultState(Path)
% ---------------------------------------------------------
State = struct();
State.Verbose = true;
% ---------------------------------------------------------
% Protocol values
State.Protocol = struct();
[~, State.Protocol.Name] = fileparts(Path);
State.Protocol.Path = Path;
State.Protocol.JSON.Name = State.Protocol.Name;
State.Protocol.JSON.BIDSVersion = '1.8.0';
State.Protocol.JSON.DatasetType = 'raw';
State.Protocol.JSON.GeneratedBy.Name = 'Woolcock Institute of Medical Research, Sydney, Australia';
State.Protocol.JSON.GeneratedBy.Version = '11/02/2022';
State.Protocol.JSON.GeneratedBy.Description = 'Preprocessing and analysis pipeline for high-density EEG (sleep) recordings in healthy controls and affected populations.';
State.Protocol.JSON.License = 'Public Domain';
State.Protocol.JSON.Authors = {''};
State.Protocol.JSON.Acknowledgements = '';
State.Protocol.JSON.HowToAcknowledge = '';
State.Protocol.JSON.Funding = {''};
State.Protocol.JSON.EthicsApprovals = {''};
State.Protocol.JSON.ReferencesAndLinks = {''};
State.Protocol.JSON.DatasetDOI = '10.xxxx';
% ---------------------------------------------------------
State.Subjects = table();
State.Files = table();
% ---------------------------------------------------------
% Keep track of processes and results
State.Processes = struct();
State.Processes.OutputPath = '';
State.Processes.Name = '';
State.Processes.Function = '';
State.Processes.ArgIn = {''};
State.Processes.StartDateTime = '';
State.Processes(1) = [];
% ---------------------------------------------------------
State.Results = struct();
State.Results.ArgOut = {''};
State.Results.Process = struct();
State.Results.Errors = '';
State.Results.Warnings = '';
State.Results(1) = [];

end