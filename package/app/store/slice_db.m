% SLICE_DB
% Contains the state related to the JSON files stored in ./app/db
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
        function state = view(obj, key)
            try
                % Check to see this field exists
                if ~isprop(obj, key)
                    error('The field ''%s'' does not exist in the ''auth'' slice.')
                end
                % Execute middleware
                app_store.getInstance().applyMiddleware('auth', 'view');
                % If no error was thrown, all is ok and we can return the value
                state = obj.(lower(key));
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''view'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        function update(obj, key, val)
            try
                % Check to see this field exists
                if ~isprop(obj, key)
                    error('The field ''%s'' does not exist in the ''ui'' slice.')
                end
                % Execute middleware
                app_store.getInstance().applyMiddleware('auth', 'update', 'PrevState', obj.(key), 'NewState', val);
                % If no error was thrown, all is ok and we can return the state
                obj.(key) = val;
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
    end
end