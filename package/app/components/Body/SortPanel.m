% SORTPANEL
% Sort panel at the top-right of the app (second row)

% Authors:
%   Sapir Bar, Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-22, Sapir Bar

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef SortPanel < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = SortPanel(parent, varargin)
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
                % ---------------------------------------------------------------------
                % Main panel
                Obj.comps.Panel = uipanel(Obj, ...
                    'BackgroundColor', props.style.colors.background.primary, ...
                    'BorderType', 'none', ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
                
                % ---------------------------------------------------------------------
                % Grid layout
                Obj.comps.Grid = uigridlayout(Obj.comps.Panel, ...
                    'ColumnWidth', {'1x'}, ...
                    'RowHeight', {20}, ...
                    'Padding', [10 10 10 10], ...
                    'RowSpacing', 5, ...
                    'ColumnSpacing', props.style.spacing.sm, ...
                    'BackgroundColor', props.style.colors.background.primary);
                
                % ---------------------------------------------------------------------
                % Drop-down inside grid
                Obj.comps.DropDown = uidropdown(Obj.comps.Grid, ...
                    'Items', {'Sort by: Subject','Sort by: Session','Sort by: Run','Sort by: Task'}, ...
                    'Value','Sort by: Subject', ...
                    'BackgroundColor', props.style.colors.button.light, ...
                    'FontSize', props.style.typography.base.size, ...
                    'FontWeight', props.style.typography.button.fontWeight, ...
                    'FontColor', props.style.colors.buttontext.dark, ...
                    'ValueChangedFcn', @(dd,event) Obj.Sorting(dd, event));
                
                Obj.comps.DropDown.Layout.Row = 1;
                Obj.comps.DropDown.Layout.Column = 1;

                % Add event listeners
                store = app_store.getInstance();                
                addlistener(store, 'sortChanged', @(store, event) Obj.update()); % ADDLISTENER(hSource, Eventname, callbackFcn)

            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''setup'' in %s.', mfilename('class')))
            end
        end

        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        function update(Obj)
            try                
                store = app_store.getInstance();
                sort_response=store.ds.currentSortField;
                fprintf('Sorting option has been changed to -> %s\n',sort_response);
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')));
            end
        end

        function Sorting(Obj, btn, event)
            try
                payload=struct();
                payload.SortResponse=Obj.comps.DropDown.Value;

                app_callback(btn, event, @sort_changed, payload, {'sortChanged'}); %(source, event, callbackfx, payload, eventlabels)
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''Sorting'' in %s.', mfilename('class')));

            end
        end
    end
end