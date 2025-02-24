% SLICE_UI
% Contains the state related to the user interface
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef slice_ui < handle
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        screensize
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function obj = slice_ui()
            % -------------------------------------------------------------
            % Initialize state
            fprintf('[%s] initialising slice: ui.\n', char(datetime(), 'HH:mm:ss'))
            g = groot();
            obj.screensize = g.ScreenSize(3:4);
        end
    end
    % =====================================================================
    % Methods for getting and setting the state
    methods
        % -----------------------------------------------------------------
        function state = view(obj, key)
            try
                % Check to see this field exists
                if ~isprop(obj, key)
                    error('The field ''%s'' does not exist in the ''ui'' slice.')
                end
                % Execute middleware
                app_store.getInstance().applyMiddleware('ui', 'view');
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
                app_store.getInstance().applyMiddleware('ui', 'update', 'PrevState', obj.(key), 'NewState', val);
                % If no error was thrown, all is ok and we can return the state
                obj.(key) = val;
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
    end
end