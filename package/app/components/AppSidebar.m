% APPSIDEBAR
% Vertical menu on the left side of the application

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-21, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef AppSidebar < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = AppSidebar(parent, varargin)
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
                    'ColumnWidth', {'1x'}, ...
                    'RowHeight', {45, props.style.spacing.lg, props.style.spacing.lg + 2*props.style.spacing.sm, '1x', 150}, ...
                    'Padding', [props.style.spacing.lg, props.style.spacing.lg, 0, props.style.spacing.lg], ...
                    'ColumnSpacing', 0, ...
                    'RowSpacing', 0);
                Obj.comps.Logo = uiimage(Obj.comps.GridLayout, ...
                    'ImageSource', 'logo.png', ...
                    'HorizontalAlignment', 'left', ...
                    'ScaleMethod', 'fit');
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
            Obj.comps.DatabasePanel = DatabasePanel(Obj.comps.GridLayout, 'style', props.style);
            Obj.comps.DatabasePanel.Layout.Row = 3;
            Obj.comps.DatabasePanel.Layout.Column = 1;
        end
    end
end