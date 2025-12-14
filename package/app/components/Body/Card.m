% CARD
% Shows the files names in the selected folder

% Authors:
%   Sapir Bar, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-22, Rick Wassing

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef Card < matlab.ui.componentcontainer.ComponentContainer
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
        function Obj = Card(parent, varargin)
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
                'Title', 'DATABASE', ...
                'BackgroundColor', props.style.colors.background.light, ...
                'BorderColor', props.style.borders.color, ...
                'BorderType', props.style.borders.type, ...
                'BorderWidth',props.style.borders.width, ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
                
                Obj.comps.Grid = uigridlayout(Obj.comps.Panel, [1,1]);
                Obj.comps.Grid.Padding = [0 0 0 0];
                Obj.comps.Grid.RowSpacing = 0;
                Obj.comps.Grid.ColumnSpacing = 0;

                Obj.comps.Tree = uitree(Obj.comps.Grid, ...
                    'Multiselect','on', ...
                    'SelectionChangedFcn', @(src,event) Obj.treeSelectionChanged(event));
                
                Obj.comps.Tree.Layout.Row = 1;
                Obj.comps.Tree.Layout.Column = 1;

                store = app_store.getInstance();
                addlistener(store,'dsChanged',@(src,event) Obj.update());
                addlistener(store,'sortChanged',@(src,event) Obj.update());
                addlistener(store,'filterChanged',@(src,event) Obj.update());

            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''setup'' in %s.', mfilename('class')))
            end
                
        end

        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        % -----------------------------------------------------------------
        function update(Obj)
            try
                store = app_store.getInstance();
                files_fullT = store.ds.files_all;

                % If no tree yet ->return
                if isempty(Obj.comps.Tree)
                    return
                end
        
                % Apply filter if exists
                if ~isempty(store.ds.currentFilter)
                    files_fullT = Obj.applyFilter(files_fullT, store.ds.currentFilter);
                end
        
                % Clear existing tree children - as this function runs everytime ds/sort/filter changed and we need to rearrange
                try
                    if ~isempty(Obj.comps.Tree.Children)
                        delete(Obj.comps.Tree.Children);
                    end
                catch
                    % ignore delete errors
                end
        
                % single root node
                rootNode = uitreenode(Obj.comps.Tree, 'Text', 'Files');
        
                if isempty(files_fullT) || height(files_fullT) == 0
                    uitreenode(rootNode, 'Text', '(No files)');
                    expand(rootNode);
                    drawnow;
                    return
                end

                if isempty(store.ds.currentSortField)
                    sort_option = 'Sort by: Subject';
                else
                    sort_option = store.ds.currentSortField;
                end
                
                ChangeSorting(Obj, sort_option, files_fullT, rootNode)
            catch ME
            printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')));
            end
        end

        
        function ChangeSorting (Obj, sort_option, files_fullT,rootNode)
            try    
                switch sort_option
                    case 'Sort by: Session'
                        sort_values = cellfun(@(k) k.ses, files_fullT.KeyVals, 'UniformOutput', false);
                    case 'Sort by: Run'
                        sort_values = cellfun(@(k) k.run, files_fullT.KeyVals, 'UniformOutput', false);
                    case 'Sort by: Task'
                        sort_values = cellfun(@(k) k.task, files_fullT.KeyVals, 'UniformOutput', false);
                    case 'Sort by: Subject'
                        sort_values = cellfun(@(k) k.sub, files_fullT.KeyVals, 'UniformOutput', false);
                    otherwise
                        sort_values = cellfun(@(k) k.sub, files_fullT.KeyVals, 'UniformOutput', false);
                end
    
                % Convert to numeric if possible - if not , it will return value of NaN
                numeric_vals = str2double(sort_values);

                isNumeric = ~any(isnan(numeric_vals)); %if numeric - 1, if not :0 
    
                if isNumeric % return just the pattern of the sorting (like : 1,2,3...) 
                    sort_values_unique = unique(numeric_vals);  % ascending numeric
                else
                    sort_values_unique = sort(unique(sort_values));  % ascending strings
                end
    
                % Loop over groups
                for i = 1:numel(sort_values_unique)
                    cur_val = sort_values_unique(i);
                    if isNumeric
                        cur_val_str = num2str(cur_val); % numeric -> string
                        group_idx = numeric_vals == cur_val;
                    else
                        cur_val_str = string(cur_val); % convert cell content to string scalar
                        group_idx = strcmp(sort_values, cur_val);
                    end
                    
                    % creating a treenode for this specific value of sorting
                    gNode = uitreenode(rootNode, 'Text', cur_val_str);
                    groupFiles = files_fullT(group_idx, :);

                    % Add child nodes
                    for f = 1:height(groupFiles)
                        filePath = groupFiles.Path{f};
                        [~, name, ext] = fileparts(filePath);
                        label = [name ext];
                        nd = struct();
                        nd.Path = filePath;
                        nd.KeyVals = groupFiles.KeyVals{f};
                        nd.Row = table2struct(groupFiles(f, :));
                        uitreenode(gNode, 'Text', label, 'NodeData', nd);
                    end
                end

            expand(rootNode);
            drawnow;
    
            catch ME
            printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')));
            end
        end


        function files_filtered = applyFilter(Obj, files, filter)
        
            idx = true(height(files),1);  % start with all true
            
            % Filter by subject
            if isfield(filter, 'sub') && ~isempty(filter.sub)
                kv = cellfun(@(k) k.sub, files.KeyVals, 'UniformOutput', false);
                idx = idx & ismember(kv, filter.sub);
            end
        
            % Filter by session
            if isfield(filter, 'ses') && ~isempty(filter.ses)
                kv = cellfun(@(k) k.ses, files.KeyVals, 'UniformOutput', false);
                idx = idx & ismember(kv, filter.ses);
            end
        
            % Filter by run
            if isfield(filter, 'run') && ~isempty(filter.run)
                kv = cellfun(@(k) k.run, files.KeyVals, 'UniformOutput', false);
                idx = idx & ismember(kv, filter.run);
            end
        
            % Filter by task
            if isfield(filter, 'task') && ~isempty(filter.task)
                kv = cellfun(@(k) k.task, files.KeyVals, 'UniformOutput', false);
                idx = idx & ismember(kv, filter.task);
            end
        
            % Filter by Type (correct version)
            if isfield(filter, 'Type') && ~isempty(filter.Type)
                idx = idx & ismember(files.Type, filter.Type);
            end
        
            files_filtered = files(idx,:);
        end


        function treeSelectionChanged(Obj, event)
            try
                selectedNodes = event.SelectedNodes;
                if isempty(selectedNodes)
                    return
                end
                % keyboard;
                for i = 1:numel(selectedNodes)
                    node = selectedNodes(i);
                    nd = node.NodeData;
                    % accept struct (as we set above), table row, or char
                    if isstruct(nd) && isfield(nd, 'Path')
                        fprintf('Selected file: %s\n', nd.Path);
                    elseif istable(nd) && ismember('Path', nd.Properties.VariableNames)
                        fprintf('Selected file: %s\n', nd.Path{1});
                    elseif ischar(nd) || isstring(nd)
                        fprintf('Selected file: %s\n', char(nd));
                    else
                        % nothing
                    end
                end

            catch ME
                printerrormessage(ME, sprintf('Error in treeSelectionChanged in %s.', mfilename('class')));
            end
        end
    end
end