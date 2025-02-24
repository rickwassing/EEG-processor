% APP_STORE
% Central store to keep the application state and where all components can
% subscribe to state changes using event listeners.
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef app_store < handle
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        ui; % User interface
        auth; % Authentication
        db; % All database documents
        ds; % BIDS dataset
        proc; % Processes to mutate the BIDS dataset
        listeners; % Handle to event listeners that components are subscribed to
        middleware; % To log changes, and potentially validate state changes
    end
    % =====================================================================
    % Event list
    events
        uiChanged;
        authChanged;
        dbChanged;
        dsChanged;
        procChanged;
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function obj = app_store(app_path)
            % -------------------------------------------------------------
            % Initialize state with multiple slices
            g = groot();
            obj.ui = slice_ui();
            obj.auth = slice_auth();
            obj.db = slice_db(app_path);
            obj.ds = slice_ds();
            % -------------------------------------------------------------
            obj.proc = {};
            obj.middleware = {}; % Middleware stack
            obj.listeners = struct(); % Handles to event listeners
        end
    end
    % =====================================================================
    % Returns the handle to the store
    methods (Static)
        function obj = getInstance(app_path)
            persistent instance;
            if isempty(instance)
                instance = app_store(app_path);
            end
            obj = instance;
        end
    end
    % =====================================================================
    % Methods for getting and setting the state
    methods
        % -----------------------------------------------------------------
        % Add middleware
        function setMiddleware(obj, middlewareFx)
            obj.middleware{end+1} = middlewareFx;
        end
        % -----------------------------------------------------------------
        % Execute middleware
        function execMiddleware(obj, action, slice, varargin)
            for i = 1:numel(obj.middleware)
                obj.middleware{i}(obj.auth, action, slice, varargin{:});
            end
        end
        % -----------------------------------------------------------------
        % Add processes
        function addProcess(obj, fx, file, cfg)
            % Get the name of this computer
            [~, host] = system('hostname');
            host = strtrim(host);
            % Create a new process config
            p = struct();
            p.id = getuuid();
            p.auth = obj.auth;
            p.host = host; % the name of the computer to run this process on
            p.created = char(datetime(), 'yyyy-MM-dd''T''HH:mm:ss');
            p.started = false;
            p.completed = false;
            p.fx = fx; % Function handle to apply to file
            p.file = file; % File to apply the process to
            p.cfg = cfg; % Configuration used in the function (i.e., parameters)
            % Append the process to the list
            obj.proc{end+1} = p;
        end
        % -----------------------------------------------------------------
        % Keeps track of all event listeners
        function addSliceListener(obj, sliceName, callback)
            try
                eventName = [lower(sliceName), 'Changed'];
                if isprop(obj, eventName)
                    obj.listeners.(lower(sliceName)) = addlistener(obj, eventName, @(~, ~) callback());
                else
                    error('Invalid slice name: %s', sliceName);
                end
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''addSliceListener'' in %s.', mfilename('class')))
            end
        end
    end
end