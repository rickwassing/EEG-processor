% BOILERPLATE
% Replace the all-caps name of this component on line 1. And provide a
% concise description of what this component is, and what callbacks are
% involved.

% Authors:
%   <name>, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created yyyy-mm-dd, <name>

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef boilerplate < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = boilerplate(parent, varargin)
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
        % Add more methods as needed
        function x = somemethod(Obj)
            % Do something
            x = 0;
        end
    end
end