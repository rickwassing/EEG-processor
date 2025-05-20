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
                Obj.comps.RecentsContextMenu = uicontextmenu(props.uifigure);
                Obj.comps.RecentsContextItems = [];
                Obj.comps.Panel = uipanel(Obj, ...
                    'BorderType', 'none', ...
                    'BackgroundColor', props.style.colors.background.secondary, ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 1]);
                Obj.comps.GridLayout = uigridlayout(Obj.comps.Panel, ...
                    'BackgroundColor', props.style.colors.background.secondary, ...
                    'ColumnWidth', {'1x', props.style.spacing.lg}, ...
                    'RowHeight', {props.style.spacing.lg}, ...
                    'Padding', props.style.spacing.sm, ...
                    'ColumnSpacing', props.style.spacing.sm, ...
                    'RowSpacing', 0);
                Obj.comps.Label = uilabel(Obj.comps.GridLayout, ...
                    'Text', '', ...
                    'WordWrap', 'off', ...
                    'FontName', props.style.typography.base.font, ...
                    'FontSize', props.style.typography.base.size, ...
                    'FontColor', props.style.colors.text.dark);
                Obj.comps.OpenButton = StyledButton(Obj.comps.GridLayout, 'primary', props.style, ...
                    'Icon', 'icon-folder-open-light.png', ...
                    'Text', '', ...
                    'ContextMenu', Obj.comps.RecentsContextMenu, ...
                    'ButtonPushedFcn', @(src, event) Obj.loadDataset(src, event, 'getdir', props.getdir));
                % Add event listeners
                store = app_store.getInstance();
                addlistener(store, 'dsChanged', @(store, event) Obj.update());
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''setup'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        function update(Obj)
            try
                store = app_store.getInstance();
                Obj.comps.Label.Text = store.ds.path;
                if isfield(store.db.state.app, 'recent')
                    Obj.renderContextMenuItems(store.db.state.app.recent)
                else
                    Obj.renderContextMenuItems([])
                end
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        function renderContextMenuItems(Obj, recents)
            try
                % Only render the recent items that can be loaded on this system
                recents = filterpaths(recents);
                % Render menu items for the recent paths
                for i = 1:numel(recents)
                    doRender = false; % Assume we don't have to render
                    if length(Obj.comps.RecentsContextItems) < i
                        doRender = true; % Render: the handle does not exist yet
                    elseif ~isvalid(Obj.comps.RecentsContextItems(i).handle)
                        doRender = true; % Render: the handle is invalid
                    end
                    if doRender
                        % Render the UIMenu item
                        Obj.comps.RecentsContextItems(i).handle = uimenu(Obj.comps.RecentsContextMenu, ...
                            'Text', recents{i}, ...
                            'MenuSelectedFcn', @(src, event) Obj.loadDataset(src, event, 'path', recents{i}));
                    else
                        % Update the properties of the UIMenu item
                        Obj.comps.RecentsContextItems(i).handle.Text = recents{i};
                        Obj.comps.RecentsContextItems(i).handle.MenuSelectedFcn = @(src, event) Obj.loadDataset(src, event, 'path', recents{i});
                    end
                end
                % Delete any unnecessary menu items
                for i = length(Obj.comps.RecentsContextItems):-1:length(recents)+1
                    delete(Obj.comps.RecentsContextItems(i).handle)
                    Obj.comps.RecentsContextItems(i) = [];
                end
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''renderContextMenuItems'' in %s.', mfilename('class')))
            end
        end
    end
    % =====================================================================
    % Private methods with callbacks
    methods (Access = protected)
        % -----------------------------------------------------------------
        % Allows the user to select a folder, and executes callback
        function loadDataset(Obj, source, event, varargin) %#ok<INUSD>
            try
                payload = struct();
                props = parsevarargin(varargin);
                if isfield(props, 'path')
                    % Path was selected from the context menu
                    payload.path = props.path;
                else
                    % Open interface where the user can select a directory
                    payload.path = props.getdir();
                    if ispc % Make sure we use forward slashes only
                        payload.path = strrep(payload.path, '\', '/');
                    end
                end
                % Check if user pressed cancel > show message and return to app
                if payload.path == 0
                    return
                end
                app_callback(source, event, @ds_updatepath, payload, {'dsChanged'})
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''loadDataset'' in %s.', mfilename('class')))
            end
        end
    end
end