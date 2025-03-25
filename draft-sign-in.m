%%To think about the position         
% Create NameEditFieldLabel_7
        app.NameEditFieldLabel_7 = uilabel(app.DatasetGeneratedByGridLayout);
        app.NameEditFieldLabel_7.HorizontalAlignment = 'right';
        app.NameEditFieldLabel_7.FontSize = 10;
        app.NameEditFieldLabel_7.Layout.Row = 1;
        app.NameEditFieldLabel_7.Layout.Column = 1;
        app.NameEditFieldLabel_7.Text = 'Name';


        % Button pushed function: AuthButton
        function AuthButtonPushed(app, event)
            try
                % ---------------------------------------------------------
                % Disable button to prevent double clicking
                event.Source.Enable = 'off'; drawnow;
                % ---------------------------------------------------------
                % Call the GUI
                switch lower(event.Source.Text)
                    case 'sign in'
                        app.GUIs.SimpleQuestion = SimpleQuestion(app, 'Enter your name please', '');
                        uiwait(app.GUIs.SimpleQuestion.UIFigure);
                        % ---------------------------------------------------------
                        % Check if user pressed cancel
                        if ~app.Import.Return
                            event.Source.Enable = 'on';
                            return
                        end
                        % Make sure the value is an alphanumeric string
                        newValue = lower(regexprep(app.Import.Data.Answer, '[^a-zA-Z0-9]', ''));
                        newValue(1) = upper(newValue(1));
                    case 'sign out'
                        newValue = '';
                end
                % ---------------------------------------------------------
                % SET STATE
                if isempty(newValue)
                    app.State.Auth.IsAuthorized = false;
                    app.State.Auth.Name = '';
                else
                    app.State.Auth.IsAuthorized = true;
                    app.State.Auth.Name = newValue;
                end
                % ---------------------------------------------------------
                % RENDER
                app.RenderAuthLabel();
                % ---------------------------------------------------------
                % Reset is loading
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

