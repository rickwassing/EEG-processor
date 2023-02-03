function [app, DatasetLoaded] = SelectAndLoadDataset(app)
% ---------------------------------------------------------
% Initialize
currentPath = '';
if isfield(app.State, 'Protocol')
    currentPath = app.State.Protocol.Path;
end
DatasetLoaded = false;
% ---------------------------------------------------------
while ~DatasetLoaded
    % ---------------------------------------------------------
    % Ask to locate dataset
    app.State.Protocol.Path = uigetdir('.', 'Select the folder where your dataset is located');
    % -----
    % Check if user pressed cancel > show message and return to app
    if app.State.Protocol.Path == 0
        sel = uiconfirm(app.UIFigure, 'You did not select a folder...', 'Error', ...
            'Options',{'Cancel', 'Try again'},...
            'DefaultOption', 'Try again', ...
            'Icon', 'error');
        switch sel
            case 'Cancel'
                if isfield(app.State, 'Protocol')
                    app.State.Protocol.Path = currentPath;
                end
                return
            otherwise
                continue
        end
        % ---------------------------------------------------------
        % Check if dataset exists, if so load it and we're done
    elseif ...
            exist([app.State.Protocol.Path, '/dataset_description.json'], 'file') ~= 0 || ...
            exist([app.State.Protocol.Path, '/rawdata/dataset_description.json'], 'file') ~= 0
        % try loading the JSON file, if 'error', then notify the user
        try
            % Force forward slashes
            app.State.Protocol.Path = strrep(app.State.Protocol.Path, filesep, '/');
            % Get the default JSON structure
            defJSON = DefaultState(app.State.Protocol.Path);
            app.State.Protocol.Name = defJSON.Protocol.Name;
            defJSON = defJSON.Protocol.JSON;
            % Load the JSON from disk
            if exist([app.State.Protocol.Path, '/dataset_description.json'], 'file') ~= 0
                % ---------------------------------------------------------
                % EDIT 28 March 2022: 
                % Backwards compatibility with BIDS processor version 1. In
                % this version, the JSON file was kept in the root
                % directory and not in the raw data directory which was not
                % precisely meeting the BIDS criteria. So, load the JSON
                % and save it in the raw data folder, and remove the JSON
                % file from the root folder
                % ---------------------------------------------------------
                % Load the JSON file
                app.State.Protocol.JSON = json2struct([app.State.Protocol.Path, '/dataset_description.json']);
                % Save the JSON file in the right location
                struct2json(app.State.Protocol.JSON, [app.State.Protocol.Path, '/rawdata/dataset_description.json'])
                % Delete the JSON file from the root dir
                DeleteFileSystemCommand([app.State.Protocol.Path, '/dataset_description.json']);
            else
                % ---------------------------------------------------------
                % Load the JSON file
                app.State.Protocol.JSON = json2struct([app.State.Protocol.Path, '/rawdata/dataset_description.json']);
            end
            % Soft copy over all the fields in the disk version to the
            % default version. This way we can make sure all fields are
            % populated.
            fnames = {'Name', 'BIDSVersion', 'DatasetType', 'GeneratedBy', 'License', 'Authors', 'Acknowledgements', 'HowToAcknowledge', 'Funding', 'EthicsApprovals', 'ReferencesAndLinks', 'DatasetDOI'};
            for i = 1:length(fnames)
                % If the field not already exists in the disk version, copy
                % the default values over
                if ~isfield(app.State.Protocol.JSON, fnames{i})
                    app.State.Protocol.JSON.(fnames{i}) = defJSON.(fnames{i});
                end
                % There must be a value for the license
                if isempty(app.State.Protocol.JSON.License)
                    app.State.Protocol.JSON.License = 'Public Domain';
                end
            end
        catch ME
            printME(ME)
            sel = uiconfirm(app.UIFigure, 'Sorry, an unexpected error occurred when loading the dataset. Nothing is loaded. See the Matlab Command Window for more info.', 'Error', ...
                'Options',{'Ok'},...
                'DefaultOption', 'Ok', ...
                'Icon', 'error'); %#ok<NASGU>
            return
        end
        DatasetLoaded = true;
        % ---------------------------------------------------------
        % Else DB does not exist
    else
        % Force forward slashes
        app.State.Protocol.Path = strrep(app.State.Protocol.Path, filesep, '/');
        % Ask the user if they want to create a new dataset
        sel = uiconfirm(app.UIFigure, {'This folder does not contain a dataset yet.', 'Do you want to create a new one?'}, 'Question', ...
            'Options',{'No, select another dataset', 'Yes, create a new dataset'},...
            'DefaultOption', 'Yes, create a new dataset', ...
            'Icon', 'question');
        switch sel
            case 'Yes, create a new dataset'
                % ---------------------------------------------------------
                % Initialize the State
                app.InitializeState(app.State.Protocol.Path);
                DatasetLoaded = true;
            otherwise
                continue % Go again from the top
        end
    end
end

    function [status, cmdout] = DeleteFileSystemCommand(Path)
        % ---------------------------------------------------------
        % Create the command
        ArgIn = strrep(Path, '/', filesep);
        if ispc
            cmd = ['del \f "', ArgIn, '"'];
        else
            cmd = ['rm -f "', ArgIn, '"'];
        end
        % ---------------------------------------------------------
        % Run command
        [status, cmdout] = system(cmd);
    end

end