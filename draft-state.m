% App properties
    properties (Access = public)
        % App properties
        Waitbar;
        ErrorMessage;
        Import;
        State;


         % METHOD: Update DatasetPathEditField
        function RenderAuthLabel(app)
            if app.State.Verbose
                t = now;
            end
            if app.State.Auth.IsAuthorized
                UpdateProperty(app, app.AuthLabel, 'Text', sprintf('Hi %s!', app.State.Auth.Name));
            else
                UpdateProperty(app, app.AuthLabel, 'Text', '');
            end
            if app.State.Auth.IsAuthorized
                UpdateProperty(app, app.AuthButton, 'Text', 'Sign out');
            else
                UpdateProperty(app, app.AuthButton, 'Text', 'Sign in');
            end
            if app.State.Verbose
                fprintf('>> BIDS: RenderAuthLabel took %s.\n', duration2str(now-t));
            end
        end
        % ---------------------------------------------------------


         % METHOD: Sets an error message
        function RenderErrorMessage(app, Message)
            if app.State.Verbose
                t = now; %#ok<*TNOW1>
            end
            sel = uiconfirm(app.UIFigure, Message, 'Error', ...
                'Options',{'Ok'},...
                'DefaultOption', 'Ok', ...
                'Icon', 'error'); 
            drawnow;
            if app.State.Verbose
                fprintf('>> BIDS: RenderErrorMessage took %s.\n', duration2str(now-t));
            end
        end
        % METHOD: Set the value of an edit input field
        function RenderInputField(app, Obj, Value)
            if app.State.Verbose
                t = now;
            end
            if isempty(Value)
                UpdateProperty(app, Obj, 'Value', '');
            else
                UpdateProperty(app, Obj, 'Value', Value);
            end
            if app.State.Verbose
                fprintf('>> BIDS: RenderInputField took %s.\n', duration2str(now-t));
            end
        end
        % ---------------------------------------------------------
        % METHOD: Update DatasetPathEditField
        function RenderDatasetPathEditField(app)
            if app.State.Verbose
                t = now;
            end
            UpdateProperty(app, app.DatasetPathEditField, 'Value', app.State.Protocol.Path);
            if app.State.Verbose
                fprintf('>> BIDS: RenderDatasetPathEditField took %s.\n', duration2str(now-t));
            end
        end

% --------------------------------------------------------------------------------------------------------------------------------
        % Button pushed function: DatasetBrowseButton
        function DatasetBrowseButtonPushed(app, event)
            try
                % ---------------------------------------------------------
                % Check Auth status
                if ~app.State.Auth.IsAuthorized
                    app.RenderErrorMessage('Please sign in first.')
                    return
                end
                % ---------------------------------------------------------
                % Disable button to prevent double clicking
                event.Source.Enable = 'off'; drawnow;
                % ---------------------------------------------------------
                % Command Window
                fprintf('>> BIDS: Browse...\n');
                % ---------------------------------------------------------
                % Open waitbar
                app.RenderWaitbar('Select and load dataset.', -1);
                % ---------------------------------------------------------
                % Function
                DatasetLoaded = app.LoadDataset();
                % Update the object properties, but only if a Dataset is loaded
                if DatasetLoaded
                    % ---------------------------------------------------------
                    % Command Window
                    fprintf('>> BIDS: Dataset loaded\n');
                    fprintf('>> BIDS: %s\n', app.State.Protocol.Path);
                    % ---------------------------------------------------------
                    % SET STATE
                    app.SetLoading(true, []);
                    % ---------------------------------------------------------
                    % RENDER
                    % Set properties in the Dataset path panel
                    app.RenderDatasetPathEditField();
                    % Set properties in the raw and derivatives tabs
                    app.InitFilesFilterEditField();
                    % Delete all existing nodes
                    % ID #0007
                    delete(app.FilesRawTree.Children);
                    delete(app.FilesDerivativesTree.Children);
                    delete(app.FilesFirstlvlOutputTree.Children);
                    app.RenderFilesTree('raw');
                    app.RenderFilesTree('derivative');
                    app.RenderFilesTree('fstlvl');
                    app.ToggleFilesTree(true);
                    app.RenderFilesAddSubjectButton();
                    app.RenderFilesExpandButton();
                    app.RenderFilesSelectButton();
                    app.RenderFilesFilterEditField();
                    app.RenderDatasetSessionsListBox();
                    app.RenderDatasetTasksListBox();
                    % Set the properties of the add process panel
                    app.RenderFileAddProcessPanel();
                    % Set properties in the Dataset tab
                    app.RenderPropertiesTabGroup('', '');
                    app.RenderProcessesPanel(); % Fixed ID #0010
                    app.InitDatasetProperties();
                end
                % ---------------------------------------------------------
                % Close waitbar
                app.RenderWaitbar([]);
                app.SetLoading(false, []);
                event.Source.Enable = 'on';
            catch ME
                % ---------------------------------------------------------
                % Catch and print any errors
                printME(ME);
                app.RenderErrorMessage('A critical error occurred. See the command window for more information.');
                app.SetLoading(false, []);
                app.RenderWaitbar([]);
                event.Source.Enable = 'on';
            end
        end

