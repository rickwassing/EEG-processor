% APPBODY
% Main body of the application

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2026-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef AppBody < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = AppBody(parent, varargin)
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
                    'BackgroundColor', props.style.colors.background.primary, ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 1]);
                Obj.comps.GridLayout = uigridlayout(Obj.comps.Panel, ...
                    'BackgroundColor', props.style.colors.background.primary, ...
                    'ColumnWidth', {'3x', '1x'}, ...
                    'RowHeight', {props.style.logo.height, '1x'}, ...
                    'Padding', [props.style.spacing.lg, props.style.spacing.lg, props.style.spacing.lg, props.style.spacing.lg], ...
                    'ColumnSpacing', 0, ...
                    'RowSpacing', props.style.spacing.xs);
                % Create subcomponents
                Obj.createComponents(props);
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
        % -----------------------------------------------------------------
        % Create sub-components
        function createComponents(Obj, props)
            Obj.comps.DatabasePanel = DatabasePanel(Obj.comps.GridLayout, ...
                'style', props.style, ...
                'uifigure', props.uifigure, ...
                'getdir', props.getdir);
            Obj.comps.DatabasePanel.Layout.Row = 1;
            Obj.comps.DatabasePanel.Layout.Column = 1;

            Obj.comps.SignInPanel = SignInPanel(Obj.comps.GridLayout, ...
                'style', props.style, ...
                'uifigure', props.uifigure, ...
                'getdir', props.getdir);
            Obj.comps.SignInPanel.Layout.Row = 1;
            Obj.comps.SignInPanel.Layout.Column = 2;

            Obj.comps.Card = uipanel(Obj.comps.GridLayout, ...
                'Title', 'DATABASE', ...
                'BackgroundColor', props.style.colors.background.light, ...
                'BorderColor', props.style.borders.color, ...
                'BorderType', props.style.borders.type, ...
                'BorderWidth',props.style.borders.width);
            Obj.comps.Card.Layout.Row = 2;
            Obj.comps.Card.Layout.Column = [1, 2];
        end
    end
end