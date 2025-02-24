% EEG_PROCESSOR
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
%   app - [AppBase] (1, 1) Handle to the application, its components and state

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-11, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef EEG_Processor < matlab.apps.AppBase
    % #####################################################################
    % PROPERTIES
    properties (Access = public)
        comps; % Contains all handles to components
        path; % Path to this file
        settings; % Structure with the app id and style.
        store; % Contains the app complete state
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Private methods
    methods (Access = private)
        % -----------------------------------------------------------------
        % Create UIFigure and initialise
        function init(app)
            % Add the path
            app.addMatlabPath();
            % Load the app settings
            app.settings = json2struct(fullfile(app.path, 'package', 'app', 'app_settings.json'));
            % Create UIFigure and hide until all components are created
            app.comps.UIFigure = uifigure('Visible', 'off', 'Tag', 'EEG Processor');
            app.comps.UIFigure.Name = 'EEG Processor';
            % Create grid layout
            app.comps.GridLayout = uigridlayout(app.comps.UIFigure, ...
                'ColumnWidth', {225, '1x'}, ...
                'RowHeight', {'1x'}, ...
                'Padding', 0, ...
                'ColumnSpacing', 0, ...
                'RowSpacing', 0);
            % TODO refactor
            app.comps.Main = uipanel(app.comps.GridLayout, ...
                'BorderType', 'none', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'BackgroundColor', app.settings.style.colors.background.primary);
            app.comps.Main.Layout.Column = 2;

            Obj.comps.MainGridLayout = uigridlayout(app.comps.Main, ...
                'BackgroundColor', app.settings.style.colors.background.primary, ...
                'ColumnWidth', {'1x'}, ...
                'RowHeight', {350, 250}, ...
                'Padding', app.settings.style.spacing.lg, ...
                'ColumnSpacing', app.settings.style.spacing.lg, ...
                'RowSpacing', app.settings.style.spacing.lg);

            app.comps.MainPanel1 = uipanel(Obj.comps.MainGridLayout, ...
                'BorderType', 'none', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'BackgroundColor', app.settings.style.colors.background.light);

            app.comps.MainPanel1 = uipanel(Obj.comps.MainGridLayout, ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'BackgroundColor', app.settings.style.colors.background.light);


            % Initialise the app state
            app.store = app_store.getInstance(app.path);
            % Attach middleware
            app.store.setMiddleware(@logging);
            
            % Set the position of the application
            app.setPosition();
            % Show the figure after all components are created
            app.comps.UIFigure.Visible = 'on';
        end
        % -----------------------------------------------------------------
        % Create components
        function createComponents(app)
            app.comps.Sidebar = AppSidebar(app.comps.GridLayout, 'style', app.settings.style);
            app.comps.Sidebar.Layout.Row = 1;
            app.comps.Sidebar.Layout.Column = 1;
        end
        % -----------------------------------------------------------------
        % Places the interface nicely on the screen
        function setPosition(app)
            g = groot();
            h = g.ScreenSize(4)-100;
            app.comps.UIFigure.Position = [1, 100, 1000, h];
        end
        % -----------------------------------------------------------------
        % Add the full package to the Matlab path
        function addMatlabPath(app)
            % Extract and move to the full path of this file (EEG_Processor.m)
            app.path = fileparts(mfilename('fullpath'));
            % Add the full subdirectories to the path
            addpath(genpath([app.path, filesep, 'package']))
            % Load plugins: must be stored under ./plugins/<name>/latest
            plugins = dir('plugins/*');
            % Crawl through all plugins and add them to the path
            for i = 1:length(plugins)
                switch lower(plugins(i).name)
                    case 'eeglab'
                        check = which('pop_loadset.m');
                        if isempty(check)
                            addpath('plugins/eeglab')
                            eeglab();
                            close all
                        end
                    case 'fieldtrip'
                        check = which('ft_write_data.m');
                        if isempty(check)
                            addpath('plugins/fieldtrip')
                            ft_defaults();
                        end
                    case 'faster'
                        check = which('FASTER.m');
                        if isempty(check)
                            addpath('plugins/faster/latest')
                        end
                end
            end
        end
    end
    % =====================================================================
    % PUBLIC METHODS
    methods (Access = public)
        % -----------------------------------------------------------------
        % Construct app
        function app = EEG_Processor
            % Get a handle of the currently running app
            RunningApp = getRunningApp(app);
            % Check if this app is already running
            if isempty(RunningApp) % not running yet
                % Create UIFigure and initialise
                init(app)
                % Create UIFigure and components
                createComponents(app)
                % Register the app with app Designer
                registerApp(app, app.comps.UIFigure)
            else % already running
                % Focus the running singleton app
                figure(RunningApp.comps.UIFigure)
                app = RunningApp;
            end
        end
        % -----------------------------------------------------------------
        % Code that executes before app deletion
        function delete(app)
            if isempty(app.comps)
                return
            end
            % Clear the store instance
            clear app_store;
            % Delete UIFigure when app is deleted
            delete(app.comps.UIFigure)
        end
    end
end