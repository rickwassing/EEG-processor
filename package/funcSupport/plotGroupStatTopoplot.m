function H = plotGroupStatTopoplot(cope, stat, p_unc, p_cor, t_unc, t_cor, chanlocs, surface, varargin)
% --------------------------------------------------
% Init default values
if exist('colormap_roma.mat', 'file') == 2
    ColorMap = load('colormap_roma.mat');
    ColorMap = ColorMap.roma;
elseif exist('colormap_batlow.mat', 'file') == 2
    ColorMap = load('colormap_batlow.mat');
    ColorMap = ColorMap.batlow;
else
    ColorMap = parula();
end
UncMarkerSize = 12;
PermMarkerSize = 13;
UncMarkerColor = [0.9100, 0.7610, 0.0900];
PermMarkerColor = [1, 1, 1];
if isempty(cope)
    FigPosition = [0 450 560 420];
else
    FigPosition = [0 450 1120 420];
end
FigTitle = '';
FigTitleFontSize = 12;
FigTitleFontWeight = 'bold';
CBarLabel = '';
CBarFontSize = 12;
CBarFontWeight = 'bold';
TopoplotStyle = 'map';
ShowColorbar = true;
outpath = './group_analysis.png';
doSave = false;
CLim = NaN;
clusters = struct();
clusters(1) = [];
% Check if the figure handle is supplied
IsFigHandle = false;
% --------------------------------------------------
% Parse the variable arguments in
if nargin > 8
    for i = 1:2:length(varargin)
        Param = varargin{i};
        Value = varargin{i+1};
        if ~ischar(Param)
            error('Additional arguments must be strings')
        end
        Param = lower(Param);
        switch Param
            case 'fig'
                H(1).Fig = Value;
                IsFigHandle = true;
            case 'figposition'
                FigPosition  = Value;
            case 'figtitle'
                FigTitle  = Value;
            case 'figtitlefontsize'
                FigTitleFontSize  = Value;
            case 'figtitlefontweight'
                FigTitleFontWeight  = Value;
            case 'cbarlabel'
                CBarLabel = Value;
            case 'cbarfontsize'
                CBarFontSize  = Value;
            case 'cbarfontweight'
                CBarFontWeight  = Value;
            case 'clim'
                CLim  = Value;
            case 'uncmarkersize'
                UncMarkerSize = Value;
            case 'permmarkersize'
                PermMarkerSize = Value;
            case 'uncmarkercolor'
                UncMarkerColor = Value;
            case 'permmarkercolor'
                PermMarkerColor = Value;
            case 'topoplotstyle'
                TopoplotStyle = Value;
            case 'colormap'
                ColorMap = Value;
            case 'showcolorbar'
                ShowColorbar = Value;
            case 'outpath'
                outpath = Value;
            case 'dosave'
                doSave = Value;
            case 'clusters'
                clusters = Value;
        end
    end
end
% --------------------------------------------------
% Create and set figure
if ~IsFigHandle
    H(1).Fig = figure();
end
H(1).Fig.Position = FigPosition;
H(1).Fig.Color = 'w';

% We have to plot 2 axes
for i = 1:2
    % --------------------------------------------------
    if i == 1 && isempty(cope)
        continue
    end
    % --------------------------------------------------
    % Create the axis to plot the contrast of parameter estimate (cope)
    H(i).Ax = axes(H(1).Fig); %#ok<LAXES,*AGROW> 
    if isempty(cope)
        H(i).Ax.OuterPosition = [0 0 1 1];
        H(i).Ax.Title.String = FigTitle;
        H(i).Ax.Title.FontSize = FigTitleFontSize;
        H(i).Ax.Title.FontWeight = FigTitleFontWeight;
        H(i).Ax.Title.Units = 'normalized';
        H(i).Ax.Title.Position(1) = 0;
    elseif i == 1
        H(i).Ax.OuterPosition = [0 0 0.5 1];
        H(i).Ax.Title.String = FigTitle;
        H(i).Ax.Title.FontSize = FigTitleFontSize;
        H(i).Ax.Title.FontWeight = FigTitleFontWeight;
        H(i).Ax.Title.Units = 'normalized';
        H(i).Ax.Title.Position(1) = 0;
    else
        H(i).Ax.OuterPosition = [0.5 0 0.5 1];
    end
    % --------------------------------------------------
    % Plot the topoplot
    if isempty(cope)
        TData = stat;
    elseif i == 1
        TData = cope;
    else
        TData = stat;
    end
    topoplot(TData, chanlocs, ...
        'style', TopoplotStyle, ... % 'map', 'contour', 'both', 'fill', 'blank'
        'electrodes', 'on', ... % 'on', 'off', 'labels', 'numbers', 'ptslabels', 'ptsnumbers'
        'shading', 'interp', ... % 'flat', 'interp'
        'emarker', {'.', UncMarkerColor, UncMarkerSize, 1}, ...
        'emarker2', {1, '.', PermMarkerColor, PermMarkerSize, 1}, ...
        'hcolor', 'k', ...
        'whitebk', 'on', ...
        'colormap', ColorMap, ...
        'conv', 'on' ...
        );
    H(i).Ax.NextPlot = 'add';
    % --------------------------------------------------
    % Find the objects for indicating channels that are significant (uncorrected and permutation-corrected)
    H(i).UncMarker = findobj(H(i).Ax.Children, 'MarkerSize', UncMarkerSize);
    H(i).PermMarker = findobj(H(i).Ax.Children, 'MarkerSize', PermMarkerSize);
    % Store the channel locations (X, Y, and Z)
    H(i).ChanLocs = [...
        [H(i).PermMarker.XData; ascolumn(H(i).UncMarker.XData)], ...
        [H(i).PermMarker.YData; ascolumn(H(i).UncMarker.YData)], ...
        [H(i).PermMarker.ZData; ascolumn(H(i).UncMarker.ZData)], ...
        ];
    % --------------------------------------------------
    % Update the X, Y, and Z data for the significant channels (uncorrected)
    idx = p_unc <= t_unc;
    H(i).UncMarker.XData = H(i).ChanLocs(idx, 1);
    H(i).UncMarker.YData = H(i).ChanLocs(idx, 2);
    H(i).UncMarker.ZData = H(i).ChanLocs(idx, 3);
    idx = p_cor <= t_cor;
    H(i).PermMarker.XData = H(i).ChanLocs(idx, 1);
    H(i).PermMarker.YData = H(i).ChanLocs(idx, 2);
    H(i).PermMarker.ZData = H(i).ChanLocs(idx, 3);
    % --------------------------------------------------
    % Show colorbar if requested
    if ShowColorbar
        H(i).CBar = colorbar();
        if isempty(cope)
            H(i).CBar.Label.String = CBarLabel;
        elseif i == 1
            H(i).CBar.Label.String = '\beta-contrast';
        else
            H(i).CBar.Label.String = CBarLabel;
            H(i).CBar.Ticks = round(100.*[tinv([0.0000001, 0.000001, 0.00001, 0.0001, 0.001, 0.002, 0.01, 0.05]./2, 9999), abs(tinv([0.05, 0.01, 0.002, 0.001, 0.0001, 0.00001, 0.000001, 0.0000001]./2, 9999))])./100;
        end
        H(i).CBar.Label.FontSize = CBarFontSize;
        H(i).CBar.Label.FontWeight = CBarFontWeight;
    end
    if ~isempty(cope) && i == 1
        H(i).Ax.CLim = [prctile(cope, 1), prctile(cope, 99)];
        H(i).Ax.CLim = sort([-1*max(abs(H(i).Ax.CLim)), max(abs(H(i).Ax.CLim))]);
    elseif isempty(cope) || i == 2
        if CLim(1) == Inf && CLim(2) ~= Inf
            H(i).Ax.CLim(2) = CLim(2);
        elseif CLim(1) ~= Inf && CLim(2) == Inf
            H(i).Ax.CLim(1) = CLim(1);
        elseif CLim(1) ~= Inf && CLim(2) ~= Inf
            H(i).Ax.CLim = CLim;
        end
    end
    for j = 1:length(clusters)
        idx = find(ismember({chanlocs.labels}, {clusters(j).chanlocs.labels}));
        for k = 1:length(idx)
            nb = unique(surface.ConnectivityList(find(sum(surface.ConnectivityList == idx(k), 2)), :));
            nb(nb == idx(k)) = [];
            nb(~ismember(nb, idx)) = [];
            XData = nan;
            YData = nan;
            for l = 1:length(nb)
                XData = [XData, H(i).ChanLocs(idx(k), 1), H(i).ChanLocs(nb(l), 1), nan];
                YData = [YData, H(i).ChanLocs(idx(k), 2), H(i).ChanLocs(nb(l), 2), nan];
            end
            H(i).Cluster(j).Patch(k) = patch(H(i).Ax, XData, YData, [1, 1, 1], ...
                'LineStyle', '-', ...
                'LineWidth', 1, ...
                'Marker', '.', ...
                'MarkerSize', UncMarkerSize, ...
                'MarkerFaceColor', ifelse(clusters(j).issig, 'w', 'k'), ...
                'EdgeColor', ifelse(clusters(j).issig, 'w', 'k'), ...
                'EdgeAlpha', 0.5);
        end
        [~, clustlabelidx] = min((H(i).ChanLocs(idx, 1)-mean(H(i).ChanLocs(idx, 1))).^2 + (H(i).ChanLocs(idx, 2)-mean(H(i).ChanLocs(idx, 2))).^2);
        XData = H(i).ChanLocs(idx(clustlabelidx), 1);
        YData = H(i).ChanLocs(idx(clustlabelidx), 2);
        Theta = cart2pol(XData, YData);
        [XData, YData] = pol2cart(Theta, 0.525);
        H(i).Cluster(j).Text = text(H(i).Ax, XData, YData, 1, sprintf('%i', j), ...
            'FontSize', 8, ...
            'FontAngle', 'italic', ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Color', [0.25 0.25 0.25]);
        plot(H(i).Ax, [XData, H(i).ChanLocs(idx(clustlabelidx), 1)], [YData, H(i).ChanLocs(idx(clustlabelidx), 2)], '-k')
    end
end
if ~isempty(cope)
    H(1).Surf = findobj(H(1).Ax.Children, 'Type', 'surface');
end
H(2).Surf = findobj(H(2).Ax.Children, 'Type', 'surface');

if doSave
    exportgraphics(H(1).Fig, outpath, 'Resolution', 300);
end

end