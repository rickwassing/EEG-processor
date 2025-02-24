% DATABASEPANEL
% Shows the path of the selected database and allows the user to change the
% database.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-20, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef DatabasePanel < matlab.ui.componentcontainer.ComponentContainer
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        state; % The component's state
    end
    % =====================================================================
    % Private properties for sub-component handles that users cannot access
    properties (Access = private, Transient, NonCopyable)
        comps; % Contains all handles to sub-components
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function Obj = DatabasePanel(parent, varargin)
            % Use the parent user-data to pass the varargin
            parent.UserData.tmp = varargin;
            Obj@matlab.ui.componentcontainer.ComponentContainer('Parent', parent);
        end
    end
    % =====================================================================
    % Private methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        % Create the component
        function setup(Obj)
            try
                % Extract the varargin from the parent's user-data
                props = parsevarargin(Obj.Parent.UserData.tmp);
                % Create this component
                Obj.comps.Panel = uipanel(Obj, ...
                    'BorderType', 'none', ...
                    'BackgroundColor', props.style.colors.background.secondary, ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 1]);
                Obj.comps.GridLayout = uigridlayout(Obj.comps.Panel, ...
                    'BackgroundColor', props.style.colors.background.secondary, ...
                    'ColumnWidth', {'1x', props.style.spacing.lg, props.style.spacing.lg}, ...
                    'RowHeight', {props.style.spacing.lg}, ...
                    'Padding', props.style.spacing.sm, ...
                    'ColumnSpacing', props.style.spacing.sm, ...
                    'RowSpacing', 0);
                Obj.comps.Label = uilabel(Obj.comps.GridLayout, ...
                    'Text', 'database', ...
                    'WordWrap', 'off', ...
                    'FontName', props.style.typography.base.font, ...
                    'FontSize', props.style.typography.base.size, ...
                    'FontColor', props.style.colors.text.dark);
                Obj.comps.OpenButton = StyledButton(Obj.comps.GridLayout, 'primary', props.style, ...
                    'Icon', 'icon-folder-open-light.png', ...
                    'Text', '', ...
                    'ButtonPushedFcn', @(src, event) Obj.loadDatabase());
                Obj.comps.QuickMenuButton = StyledButton(Obj.comps.GridLayout, 'primary', props.style, ...
                    'Icon', 'icon-list-light.png', ...
                    'Text', '', ...
                    'ButtonPushedFcn', @(src, event) disp('Open modal to select recent datasets'));
                
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''setup'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        function update(Obj)
            try
                % Do something
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
        % Allows the user to select a folder and broadcasts an event to the
        % app that a new dataset has been selected
        function loadDatabase(Obj)
            path = uigetdir('.', 'Select the folder where your dataset is located');
            % -----
            % Check if user pressed cancel > show message and return to app
            if path == 0
                return
            end
        end
    end
end