function plotDesignMatrix(GLM)

% Colormap
Colormap = bone();

close all

Fig = figure();
Fig.Units = 'points';
Fig.Colormap = Colormap;

Ax(1) = axes(Fig);
Ax(2) = axes(Fig);
Ax(1).Layer = 'top';
Ax(2).Layer = 'top';
Ax(1).Units = 'points';
Ax(2).Units = 'points';
Ax(1).FontSize = 10;
Ax(2).FontSize = 10;
Ax(2).NextPlot = 'add';
Ax(2).Clipping = 'off';
Ax(2).CLim = [-max(max(GLM.stats.Ttests.Contrasts)), max(max(GLM.stats.Ttests.Contrasts))];

DesMat = [];
if strcmpi(GLM.model.ModelSpec(1:5), 'Y ~ 1')
    DesMat = ones(size(GLM.input, 1), 1);
end

DesMat = [DesMat, ...
    [GLM.model.Predictors.DesMat], ...
    [GLM.model.Interactions.DesMat], ...
    [GLM.model.RandVars.DesMat], ...
    ];

imagesc(Ax(1), zscore(DesMat));

text(Ax(1), size(DesMat, 2) + 1, 0, 'EB', ...
    'FontSize', 10, ...
    'Rotation', 90);

text(Ax(1), size(DesMat, 2) + 2, 0, 'VG', ...
    'FontSize', 10, ...
    'Rotation', 90);

for i = 1:size(GLM.input, 1)
    text(Ax(1), size(DesMat, 2) + 1, i, sprintf('%i', GLM.model.ExchangeabilityBlocks(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 10)
    text(Ax(1), size(DesMat, 2) + 2, i, sprintf('%i', GLM.model.VarianceGroups(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 10)
end

Ax(1).TickLength = [0, 0];
Ax(1).XTick = 1:size(DesMat, 2);
Ax(1).XTickLabel = strrep(GLM.model.PredNames, '_', ' ');
Ax(1).XTickLabelRotation = 90;
Ax(1).XAxisLocation = 'top';

Ax(1).YDir = 'reverse';
Ax(1).YTick = 1:size(GLM.input, 1);
Ax(1).YTickLabel = strrep(reverse_fileparts(GLM.input.Path), '_', ' ');

imagesc(Ax(2), GLM.stats.Ttests.Contrasts)

for i = 1:size(GLM.stats.Ftests, 2)
    text(Ax(2), size(DesMat, 2) + i, 0, sprintf('F_{%i}', i), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 8);
    for j = 1:size(GLM.stats.Ftests, 1)
        if GLM.stats.Ftests(j, i) == 1
            plot(Ax(2), size(DesMat, 2) + i, j, 's', ...
                'Color', Colormap(128, :), ...
                'MarkerFaceColor', Colormap(128, :));
        end
    end
end

Ax(2).TickLength = [0, 0];
Ax(2).XTick = [];
Ax(2).XLim = [0.5, size(DesMat, 2)+0.5];
Ax(2).YLim = [0.5, length(GLM.stats.Ttests.Titles)+0.5];

Ax(2).YDir = 'reverse';
Ax(2).YTick = 1:length(GLM.stats.Ttests.Titles);
Ax(2).YTickLabel = GLM.stats.Ttests.Titles;

drawnow();

Ax(1).Position(3:4) = 14 .* [size(DesMat, 2), size(DesMat, 1)];
Ax(1).Position(2) = 14.*size(GLM.stats.Ttests.Contrasts, 1) + 42;

Ax(2).Position(3:4) = 14 .* [size(GLM.stats.Ttests.Contrasts, 2), size(GLM.stats.Ttests.Contrasts, 1)];
Ax(2).Position(2) = 14;
Ax(2).Box = 'on';

drawnow();

Fig.Position(3) = max([Ax(1).OuterPosition(3), Ax(2).OuterPosition(3)]);
Fig.Position(4) = Ax(1).OuterPosition(4) + Ax(2).OuterPosition(4) + 28;

Ax(1).Position(1) = max([Ax(1).Position(1), Ax(1).Position(2)]);
Ax(2).Position(1) = max([Ax(1).Position(1), Ax(1).Position(2)]);

outpath = fullfile(fileparts(GLM.filepath), 'images');
if exist(outpath, 'dir') == 0
    CreateNewDirectory(outpath)
end

exportgraphics(Fig, fullfile(outpath, 'designmatrix.png'), 'Resolution', 300);

end