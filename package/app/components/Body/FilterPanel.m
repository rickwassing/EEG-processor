% FILTERTPANEL
% Filter panel at the top-right of the app (second row)

% Authors:
%   Sapir Bar, Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-11-22, Sapir Bar

% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0

classdef FilterPanel < matlab.ui.componentcontainer.ComponentContainer
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties (Access = public)
        state; % component state
    end
    % =====================================================================
    % Private properties for sub-component handles that users cannot access
    properties (Access = private, Transient, NonCopyable)
        comps; % sub-component handles
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function Obj = FilterPanel(parent, varargin)
            parent.UserData.tmp = varargin;
            Obj@matlab.ui.componentcontainer.ComponentContainer('Parent', parent);
        end
    end
    % =====================================================================
    % Private methods
    methods (Access = protected)
        % 
        % Create the component        
        function setup(Obj)
            try
                % Extract the varargin from the parent's user-data
                props = parsevarargin(Obj.Parent.UserData.tmp);
                store = app_store.getInstance();

                % Create this component
                Obj.comps.Panel = uipanel(Obj, ...
                    'BorderType', 'none', ...
                    'BackgroundColor', props.style.colors.background.primary, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);

                % Layout inside main panel
                Obj.comps.GridLayout = uigridlayout(Obj.comps.Panel, [1 1], ...
                    'BackgroundColor', props.style.colors.background.primary);
                Obj.comps.GridLayout.RowHeight = {'1x'};
                Obj.comps.GridLayout.ColumnWidth = {'1x'};

                % Filter button
                Obj.comps.FilterButton = uibutton(Obj.comps.GridLayout, ...
                    'Text', 'Filter', ...
                    'ButtonPushedFcn', @(btn,event)Obj.createFilterPopup(), ...
                    'FontName', props.style.typography.base.font, ...
                    'FontSize', props.style.typography.base.size, ...
                    'FontWeight', props.style.typography.button.fontWeight, ...
                    'FontColor', props.style.colors.buttontext.dark, ...
                    'BackgroundColor', props.style.colors.button.light);

                addlistener(store, 'filterChanged', @(src,evt)Obj.update());

            catch ME
                printerrormessage(ME, sprintf('Error in setup of %s', mfilename('class')))
            end
        end

        % -----------------------------------------------------------------
        % Update the component, is automatically executed when properties change.
        % -----------------------------------------------------------------
        function update(Obj)
            try
                store = app_store.getInstance();
                currentFilter=store.ds.currentFilter;
                numApplied = 0;
                if ~isempty(currentFilter)
                    fn=fieldnames(currentFilter);
                    numFields = numel(fn);
                    for f=1:numFields
                        cur_field=fn{f};
                        if ~isempty(currentFilter.(cur_field))
                        numApplied = numApplied + 1;
                        end
                    end
                end
                    
                % Update Filter button text with number of filtered categories
                if numApplied > 0
                    Obj.comps.FilterButton.Text = sprintf('Filter (%d)', numApplied);
                else
                    Obj.comps.FilterButton.Text = 'Filter';
                end
              
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''update'' in %s.', mfilename('class')))
            end
        end
                
        function createFilterPopup(Obj)
            props = parsevarargin(Obj.Parent.UserData.tmp);
            store = app_store.getInstance();
            files_all = store.ds.files_all;
        
            % Figure setup (centered) 
            figWidth = 700;
            figHeight = 500;
            screenSize = get(0,'ScreenSize'); % [left bottom width height]
            figLeft = (screenSize(3) - figWidth)/2;
            figBottom = (screenSize(4) - figHeight)/2;
        
            fig = uifigure('Name','Select BIDS data to load', ...
                           'Position',[figLeft figBottom figWidth figHeight], ...
                           'Color', props.style.colors.background.primary);
        
            % Main title
            uilabel(fig,'Text','Select BIDS data to load', ...
                    'FontSize',16,'FontWeight','bold', ...
                    'HorizontalAlignment','center', ...
                    'Position',[0 figHeight-40 figWidth 30]);
        
            % Scrollable container for all categories 
            mainPanel = uipanel(fig, 'Position',[10 50 figWidth-20 figHeight-100], ...
                                'BackgroundColor', props.style.colors.background.primary, ...
                                'Scrollable','on');
        
            % Categories setup 
            categories = {'Type','sub','ses','run','task'};
            payload = struct();
            nCols = 3; 
            defaultCatHeight = 150;
            catWidth = (figWidth-40)/nCols;
        
            % Precompute heights per category
            catHeights = zeros(1,numel(categories));
            catValues = cell(1,numel(categories));
            for idx = 1:numel(categories)
                cat = categories{idx};
                if strcmp(cat,'Type')
                    values = unique(files_all.Type,'stable');
                else
                    % Other values can be found in KeyVals field
                    values = unique(cellfun(@(k) k.(cat), files_all.KeyVals,'UniformOutput',false),'stable');
                end
                values = sort(values);
                catValues{idx} = values;
                catHeights(idx) = max(defaultCatHeight, 50 + numel(values)*25);
            end
        
            % Number of rows
            nRows = ceil(numel(categories)/nCols);
        
            % Compute max height per row for alignment
            maxHeightsPerRow = zeros(1,nRows);
            for r = 1:nRows  
                idxs = (r-1)*nCols + (1:nCols);
                idxs = idxs(idxs <= numel(categories));
                maxHeightsPerRow(r) = max(catHeights(idxs));
            end
        
            % Store all checkbox handles per category
            allChecks = struct();
        
            % Create category panels 
            for idx = 1:numel(categories)
                cat = categories{idx};
                values = catValues{idx};
                nValues = numel(values);
        
                row = floor((idx-1)/nCols) + 1;
                col = mod(idx-1,nCols);
        
                xPos = col*catWidth;
                % Align top of panels in the same row
                yPos = sum(maxHeightsPerRow(row+1:end)) + 10*(nRows-row);
        
                catPanel = uipanel(mainPanel, ...
                    'Title', capitalize(cat), ...
                    'BackgroundColor', props.style.colors.background.light, ...
                    'Position',[xPos yPos catWidth maxHeightsPerRow(row)], ...
                    'Scrollable','on');
        
                % All/None buttons 
                allBtn = uibutton(catPanel,'Text','All','Position',[5 maxHeightsPerRow(row)-25 40 20]);
                noneBtn = uibutton(catPanel,'Text','None','Position',[50 maxHeightsPerRow(row)-25 40 20]);
        
                % Vertical checkboxes 
                checks = gobjects(nValues,1);
                for i = 1:nValues
                    checks(i) = uicheckbox(catPanel,'Text',string(values{i}), ...
                                           'Position',[10 maxHeightsPerRow(row)-50-i*25 140 22]);
                end
        
                allBtn.ButtonPushedFcn = @(btn,event)setAll(true,checks);
                noneBtn.ButtonPushedFcn = @(btn,event)setAll(false,checks);
        
                allChecks.(cat) = checks;
                payload.(cat) = {};
            end
        
            % Buttons setup: Load (right) & Reset (left) 
            btnWidth = 100;
            btnHeight = 30;
            gap = 10;
        
            % Load button (previously Confirm)
            loadBtn = uibutton(fig,'Text','Load', ...
                               'Position',[figWidth - btnWidth - gap, 10, btnWidth, btnHeight], ...
                               'ButtonPushedFcn', @(btn,event) confirmSelection(), ...
                               'BackgroundColor', props.style.colors.button.primary, ...
                               'FontColor', props.style.colors.buttontext.light);
        
            % Reset button (left of Load)
            resetBtn = uibutton(fig,'Text','Reset', ...
                                'Position',[figWidth - 2*btnWidth - 2*gap, 10, btnWidth, btnHeight], ...
                                'ButtonPushedFcn', @(btn,event) resetAll());
        
            % Nested functions 
            function txt = capitalize(str)
                txt = [upper(str(1)) str(2:end)];
            end
        
            function setAll(val, checks)
                for k = 1:numel(checks)
                    checks(k).Value = val;
                end
            end
        
            function confirmSelection()
                for c2 = 1:numel(categories)
                    cat2 = categories{c2};
                    checks = allChecks.(cat2);
            
                    idx = [checks.Value];
                    % FIXED LINE: convert to string array, not cell array
                    selectedTexts = string({checks(idx).Text});
            
                    payload.(cat2) = selectedTexts;
                end
            
                % Fire event
                app_callback([], [], @filter_changed, payload, {'filterChanged'});
                fig.Visible = 'off';
            end
        
            function resetAll()
                for c2 = 1:numel(categories)
                    checks = allChecks.(categories{c2});
                    for k = 1:numel(checks)
                        checks(k).Value = false;
                    end
                end
        
                % Reset Filter button text
                Obj.comps.FilterButton.Text = 'Filter';
            end
        end
    end
end