% SEARCHPANEL
% Search panel at the top-center of the app

% Authors:
%   Sapir Bar, Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-05-19, Sapir Bar

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef SearchPanel < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = SearchPanel(parent, varargin)
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
                    'RowHeight', {'1x'});

                % Create Name Input Field
                Obj.comps.SearchInput = uieditfield(Obj.comps.GridLayout, 'text', ...
                    'Placeholder', 'Search...');
                Obj.comps.SearchInput.FontColor = props.style.colors.text.secondary;
                Obj.comps.SearchInput.Layout.Row = 1;
                Obj.comps.SearchInput.Layout.Column = 1;
                Obj.comps.SearchInput.Visible = 'on';

                % Add event listeners
                store = app_store.getInstance();
                addlistener(store, 'searchChanged', @(store, event) Obj.update()); % ADDLISTENER(hSource, Eventname, callbackFcn)

            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''setup'' in %s.', mfilename('class')))
            end
        end

        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        function update(Obj)
            try
                store = app_store.getInstance();

            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
    end
end