% SIGNINPANEL
% Sign in panel at the top-right corner of the app

% Authors:
%   Sapir Bar, Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-05-19, Sapir Bar

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef SigninPanel < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = SigninPanel(parent, varargin)
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
                    'ColumnWidth', {'1.5x', '1x'}, ...
                    'RowHeight', {'1x'}, ... 
                    'Padding', repmat(props.style.spacing.sm, 1, 4), ...
                    'ColumnSpacing', props.style.spacing.sm, ...
                    'RowSpacing', props.style.spacing.sm);

                % Create Name Input Field
                Obj.comps.NameInput = uieditfield(Obj.comps.GridLayout, 'text', ...
                    'Placeholder', 'Enter your name');
                Obj.comps.NameInput.FontColor = props.style.colors.text.secondary;
                Obj.comps.NameInput.Layout.Row = 1;
                Obj.comps.NameInput.Layout.Column = 1;
                Obj.comps.NameInput.Visible = 'on';

                % Create Name Label Field
                Obj.comps.NameLabel= uilabel(Obj.comps.GridLayout, ...
                'HorizontalAlignment', 'center');
                Obj.comps.NameLabel.Layout.Row = 1;
                Obj.comps.NameLabel.Layout.Column = 1;
                Obj.comps.NameLabel.Visible = 'off';

                % Create Sign in button
                Obj.comps.SignButton = uibutton(Obj.comps.GridLayout, ...
                    'Text', 'Sign In', ...
                    'ButtonPushedFcn', @(btn,event)Obj.handleSign(btn, event), ...
                    'FontName', props.style.typography.base.font, ...
                    'FontSize', props.style.typography.base.size, ...
                    'FontWeight', props.style.typography.button.fontWeight, ...
                    'FontColor', props.style.colors.buttontext.light, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'bottom', ...
                    'BackgroundColor', props.style.colors.button.primary);
                Obj.comps.SignButton.Visible = 'on';
                Obj.comps.SignButton.Layout.Row = 1;
                Obj.comps.SignButton.Layout.Column = 2;
                
                % Add event listeners
                store = app_store.getInstance();
                addlistener(store, 'authChanged', @(store, event) Obj.update()); % ADDLISTENER(hSource, Eventname, callbackFcn)

            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''setup'' in %s.', mfilename('class')))
            end
        end

        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        function update(Obj)
            try
                store = app_store.getInstance();
                name = store.auth.username;                
                if ~isempty(name)
                    %If a name was entered, display greeting
                    Obj.comps.NameInput.Visible = 'off';
                    Obj.comps.NameLabel.Visible = 'on';
                    Obj.comps.NameLabel.Text= ['Hi ', name];
                    Obj.comps.NameLabel.HorizontalAlignment = 'right';
                    Obj.comps.SignButton.Text= 'Sign Out';

                else
                    % Add back the input field
                    Obj.comps.NameLabel.Visible = 'off';
                    Obj.comps.SignButton.Text = 'Sign In';
                    Obj.comps.NameInput.Visible= 'on';
                    Obj.comps.NameInput.Value='';
                end
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end

        % Sign in/ Sign out function
        function handleSign(Obj, btn, event)
            try
                % User clicked Sign In
                if strcmp(Obj.comps.SignButton.Text, 'Sign In') & ~isempty(Obj.comps.NameInput.Value)
                    name = strtrim(Obj.comps.NameInput.Value);

                else
                    % User clicked Sign Out
                    name = '';  % clear stored name
                end 
                
                app_callback(btn, event, @auth_changed, name, {'authChanged'}) %(source, event, callbackfx, payload, eventlabels)
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''handleSign'' in %s.', mfilename('class')))

            end
        end
    end
end

