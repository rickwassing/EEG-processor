function hyp = plotHypnogram(ax, EEG, varargin)

p = inputParser;
addParameter(p, 'Hyp', []);
addParameter(p, 'LineWidth', 7, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'numel', 1}) ...
    );
addParameter(p, 'FontSize', 10, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'numel', 1}) ...
    );
addParameter(p, 'DoPlotCycles', true, ...
    @(x) validateattributes(x, {'logical'}, {'nonempty', 'scalar', 'numel', 1}) ...
    );
parse(p,varargin{:});

DoPlotCycles = p.Results.DoPlotCycles;
lWidth = p.Results.LineWidth;
fSize  = p.Results.FontSize;
hyp = p.Results.Hyp;
if isempty(hyp)
    stages = lower({EEG.event(ismember(lower({EEG.event.type}), {'wake', 'n1', 'n2', 'n3', 'rem', 'ns'})).type});
    definition = {'wake', 'n1', 'n2', 'n3', 'rem'};
    hyp = sleep_cycles(stages, definition);
end

% Backward compatibility
if ~isfield(hyp, 'sleepstage')
    hyp.sleepstage = hyp.stage_num;
end
if ~isfield(hyp, 'sleepcycle')
    hyp.sleepcycle = hyp.cycle;
end
if ~isfield(hyp, 'sleepepisode')
    hyp.sleepepisode = hyp.episode;
end

ax.NextPlot = 'add';

YLim = [-3.5 1.5];

stairs(ax, hyp.times, hyp.sleepstage, '-', ...
    'Color', [.9 .9 .9], ...
    'LineWidth', 0.5);

for stage = -3:1
    tmp = nan(size(hyp.sleepstage));
    tmp(hyp.sleepstage == stage) = stage;
    if stage == -3; clr = standard_colors('blue').^2; end
    if stage == -2; clr = standard_colors('blue'); end
    if stage == -1; clr = standard_colors('blue').^0.5; end
    if stage == 0; clr = standard_colors('purple'); end
    if stage == 1; clr = standard_colors('red'); end
    stairs(ax, hyp.times, tmp, '-', ...
        'Color', clr, ...
        'LineWidth', lWidth);
end

for i = 1:length(EEG.event)
    switch EEG.event(i).type
        case 'boundary'
            plot([EEG.times(round(EEG.event(i).latency)), EEG.times(round(EEG.event(i).latency))]./(24*60*60), [-3, 1], ':', 'Color', [0.5, 0.5, 0.5])
        case {'arousal', 'arousalemg'}
            plot([EEG.times(round(EEG.event(i).latency)), EEG.times(round(EEG.event(i).latency) + round(EEG.event(i).duration))]./(24*60*60), [1.5, 1.5], '-', 'Color', standard_colors('red'), 'LineWidth', 2)
    end
end

if DoPlotCycles
    for cycle = 1:max(hyp.sleepcycle)
        for ep = [-1 -2 1 2]
            switch ep
                case -1
                    ColorA = standard_colors('blue').^0.5;
                    ColorB = standard_colors('blue');
                    YData = [-0.25; -0.25; 0.25; 0.25] - 4;
                case -2
                    ColorA = standard_colors('blue').^2;
                    ColorB = standard_colors('blue').^2;
                    YData = [-0.25; -0.25; 0.25; 0.25] - 4;
                case 1
                    ColorA = standard_colors('blue');
                    ColorB = standard_colors('blue').^0.5;
                    YData = [-0.25; -0.25; 0.25; 0.25] - 4;
                case 2
                    ColorA = standard_colors('purple').^0.7;
                    ColorB = standard_colors('purple').^0.3;
                    YData = [-0.25; -0.25; 0.25; 0.25] - 4;
            end
            idx = hyp.sleepepisode == ep & hyp.sleepcycle == cycle;
            if ~any(idx)
                continue
            end
            XData = [...
                hyp.times(find(idx, 1, 'first')); ...
                hyp.times(find(idx, 1, 'last')); ...
                hyp.times(find(idx, 1, 'last')); ...
                hyp.times(find(idx, 1, 'first'))];
            Vertices = [XData, YData];
            Faces = 1:4;
            CData = [...
                ColorA; ...
                ColorB; ...
                ColorB; ...
                ColorA; ...
                ];
            patch(ax, 'Faces', Faces, 'Vertices', Vertices, ...
                'FaceVertexCData', CData, ...
                'FaceColor','interp', ...
                'LineStyle', 'none');
            YLim = [-4.5 1.5];

        end
    end
end

ax.Box = 'off';
ax.TickDir = 'out';
ax.FontSize = fSize;

[~, idx] = findpeaks(-mod(hyp.times, 1/24));
idx = idx(1)-3*mean(diff(idx)):mean(diff(idx))/4:idx(end)+3*mean(diff(idx));
idx(idx < 1) = [];
idx(idx > length(hyp.times)) = [];
ax.XLim = [hyp.times(1)-5/(24*60) hyp.times(end)+5/(24*60)];
if ~any(isnan(idx)) && ~isempty(idx)
    ax.XTick = hyp.times(idx);
    labels = cellstr(datestr(hyp.times(idx), 'HH:MM')); %#ok<*DATST>
    labels(mod(datenum(labels, 'HH:MM')*24, 1) ~= 0) = {''}; %#ok<*DATNM>
    ax.XTickLabel = labels;
    ax.XTickLabelRotation = 90;
end
ax.YLim = YLim;
ax.YTick = -3:1;
ax.YTickLabel = {'N3', 'N2', 'N1', 'R', 'W'};
