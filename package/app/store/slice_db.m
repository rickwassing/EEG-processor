% SLICE_DB
% Contains the state related to the EEG Processor application itself. For
% example, it contains the 5 most recent database paths.
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef slice_db < handle
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        state
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function obj = slice_db(app_path)
            % -------------------------------------------------------------
            % Initialize state
            obj.state.app_path = app_path;
            fprintf('[%s] initialising slice: database.\n', char(datetime(), 'HH:mm:ss'))
            if exist(fullfile(app_path, 'package', 'app', 'db', 'app.json'), 'file') ~= 2
                obj.state.app = obj.initdb(app_path);
            end
            % Read all JSON files in the database
            dbfiles = dir(fullfile(app_path, 'package', 'app', 'db', '*.json'));
            for i = 1:length(dbfiles)
                [~, slice] = fileparts(dbfiles(i).name);
                fprintf('[%s] loading database: %s.\n', char(datetime(), 'HH:mm:ss'), slice)
                obj.state.(slice) = json2struct(fullfile(dbfiles(i).folder, dbfiles(i).name));
            end
        end
    end
    % =====================================================================
    % Methods for getting and setting the state
    methods
        % -----------------------------------------------------------------
        function s = initdb(obj, app_path) %#ok<INUSD>
            s = struct();
            s.app_id = getuuid();
            struct2json(s, fullfile(app_path, 'package', 'app', 'db', 'app.json'));
        end
        % -----------------------------------------------------------------
        function save(obj, slice)
            struct2json(obj.state.(slice), fullfile(obj.state.app_path, 'package', 'app', 'db', sprintf('%s.json', lower(slice))));
        end
        % -----------------------------------------------------------------
        function state = view(obj, slice)
            try
                % Execute middleware
                app_store.getInstance().execMiddleware('db', 'view');
                % If no error was thrown, all is ok and we can return the value
                state = obj.(lower(slice));
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''view'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        function obj = update(obj, slice, key, val)
            try
                % Execute middleware
                app_store.getInstance().execMiddleware('db', 'update', 'PrevState', obj.state.(slice).(key), 'NewState', val);
                % If no error was thrown, all is ok and we can return the state
                obj.state.(slice).(key) = val;
                % Write the updates to file
                obj.save(slice);
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        function obj = insert(obj, slice, key, val, varargin)
            try
                % Parse the variable arguments in
                props = parsevarargin(varargin);
                if ~isfield(props, 'makeunique')
                    props.makeunique = false;
                end
                if ~isfield(props, 'croplimit')
                    props.croplimit = -1;
                end
                % Initialize the field if it does not exist yet
                if ~isfield(obj.state.(slice), key)
                    obj.state.(slice).(key) = [];
                end
                % Execute middleware
                app_store.getInstance().execMiddleware('db', 'insert', 'PrevState', obj.state.(slice).(key), 'NewState', val);
                % If no error was thrown, all is ok and we can return the state
                obj.state.(slice).(key) = [val; ascolumn(obj.state.(slice).(key))];
                if props.makeunique
                    obj.state.(slice).(key) = unique(obj.state.(slice).(key), 'stable');
                end
                if props.croplimit > 0
                    props.croplimit = min([numel(obj.state.(slice).(key)), props.croplimit]);
                    obj.state.(slice).(key) = obj.state.(slice).(key)(1:props.croplimit);
                end
                % Write the updates to file
                obj.save(slice);
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
    end
end