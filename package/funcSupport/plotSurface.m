function H = plotSurface(P, clocs, x, y, do3d, varargin)
% Check if we need to save the figure
if nargin > 5
    doSave = true;
    outpath = varargin{1};
else
    doSave = false;
end
% --------------------------------------------------
% Create new figure with white background
H.Fig = figure();
H.Fig.Color = 'w';
H.Fig.Units = 'centimeters';
H.Fig.Position(3:4) = [30, 30];
% --------------------------------------------------
% Create new axes with equal ratios, no tick marks, and white axes
H.Ax = axes(H.Fig);
H.Triplot = triplot(P, '-k.', ...
    'MarkerSize', 66, ...
    'MarkerFaceColor', [0.4358, 0.4775, 0.5608], ...
    'MarkerEdgeColor', [0.4358, 0.4775, 0.5608], ...
    'Parent', H.Ax);
H.Ax.DataAspectRatio = [1, 1, 1];
H.Ax.XTick = [];
H.Ax.YTick = [];
H.Ax.XColor = 'w';
H.Ax.YColor = 'w';
H.Ax.ZColor = 'w';
% --------------------------------------------------
% The input for the triangulation was a 2D surface, but we're
% writing the 3D coordinates of the vertices to file. So we want to
% inspect these 3D coordinates: replace X, Y coordinates of the 2D
% vertex coordinates with the orignal 3D coordinates.
if do3d
    XData = [];
    YData = [];
    ZData = [];
    for j = 1:length(H.Triplot.XData)
        if isnan(H.Triplot.XData(j))
            XData(j) = NaN;
            YData(j) = NaN;
            ZData(j) = NaN;
            continue
        end
        idx = find(x == H.Triplot.XData(j) & y == H.Triplot.YData(j));
        XData(j) = clocs(idx).Y;
        YData(j) = clocs(idx).X;
        ZData(j) = clocs(idx).Z;
    end
    H.Triplot.XData = XData;
    H.Triplot.YData = YData;
    H.Triplot.ZData = ZData;
else 
    % Plot chanlabels
    for i = 1:length(clocs)
        if length(clocs(i).labels) > 4
            label = sprintf('%s\n%s', clocs(i).labels(1:3), clocs(i).labels(4:end));
        else
            label = clocs(i).labels;
        end
        text(H.Ax, P.Points(i, 1), P.Points(i, 2), label, ...
            'FontSize', 6, ...
            'FontWeight', 'bold', ...
            'Color', 'w', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');
    end
end

if doSave
    exportgraphics(H.Fig, outpath, 'Resolution', 300);
end

end