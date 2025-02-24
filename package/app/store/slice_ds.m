% SLICE_DS
% Contains the state (i.e., all files) in the BIDS dataset.
%
% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-24, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef slice_ds < handle
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        path;
        entities;
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function obj = slice_ds()
            % -------------------------------------------------------------
            % Initialize state
            fprintf('[%s] initialising slice: dataset.\n', char(datetime(), 'HH:mm:ss'))
            obj.path = '';
            obj.entities = struct([]);
        end
    end
    % =====================================================================
    % Methods for getting and setting the state
    methods
        % -----------------------------------------------------------------
        function state = viewOneById(obj, id)
            try
                % Check to see this field exists
                if ~isprop(obj, id)
                    error('The entity ''%s'' does not exist in the ''ds'' slice.')
                end
                % Execute middleware
                app_store.getInstance().applyMiddleware('ds', 'view', 'id', id);
                % If no error was thrown, all is ok and we can return the value
                state = obj.(lower(id));
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''viewOneById'' in %s.', mfilename('class')))
            end
        end
        % -----------------------------------------------------------------
        function updateOneById(obj, id, newFile)
            try
                % Check to see this field exists
                if ~isprop(obj, id)
                    error('The entity ''%s'' does not exist in the ''ds'' slice.')
                end
                % Execute middleware
                app_store.getInstance().applyMiddleware('ds', 'update', 'id', id);
                % If no error was thrown, all is ok and we can return the state
                obj.(id) = newFile;
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''updateOneById'' in %s.', mfilename('class')))
            end
        end
        % TODO add more methods here
    end
end