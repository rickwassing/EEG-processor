% EEG_Processor
% Application to import, process, analyse and apply statistical modeling to
% EEG data stored in accordance with the BIDS standard
%
% Usage:
%   >> app = EEG_Processor();
%
% Inputs:
%   none
%
% Outputs: 
%   app - [AppBase] (1, 1) Handle to the application and its state

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2025-02-11, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef EEG_Processor < matlab.apps.AppBase
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure  matlab.ui.Figure
    end
    % Component initialization
    methods (Access = private)
        % Create UIFigure and components
        function createComponents(app)
            % Create EEGProcessorUIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'EEG-Processor';
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    % App creation and deletion
    methods (Access = public)
        % Construct app
        function app = EEG_Processor
            % Get a handle of the currently running app
            runningApp = getRunningApp(app);
            % Check if this app is already running
            if isempty(runningApp) % not running yet
                % Create UIFigure and components
                createComponents(app)
                % Register the app with App Designer
                registerApp(app, app.UIFigure)
            else % already running
                % Focus the running singleton app
                figure(runningApp.EEGProcessorUIFigure)
                app = runningApp;
            end
        end
        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end