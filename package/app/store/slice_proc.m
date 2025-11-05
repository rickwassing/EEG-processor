% SLICE_PROC
% Contains the state related to the processes
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef slice_proc < handle
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        proc
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function obj = slice_proc()
            % -------------------------------------------------------------
            % Initialize state
            obj.proc = {};
        end
    end
    % =====================================================================
    % Methods for getting and setting the state
    methods
        % -----------------------------------------------------------------
        function state = view(obj, key)
            try
                % Execute middleware
                app_store.getInstance().execMiddleware('proc', 'view');
                % If no error was thrown, all is ok and we can return the value
                state = obj.(lower(key));
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''view'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        function update(obj, key, val)
            try
                % Execute middleware
                app_store.getInstance().execMiddleware('proc', 'update', 'PrevState', obj.(key), 'NewState', val);
                % If no error was thrown, all is ok and we can return the state
                obj.(key) = val;
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
    end
end