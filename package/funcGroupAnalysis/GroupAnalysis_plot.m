function GroupAnalysis_plot(GLM, varargin)
% --------------------------------------------------
% Check variable arguments in
doUnc = true;
doPermNonsig = true;
doPermSig = true;
doNumbers = true;
doJoints = true;
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'douncorr'
            doUnc = varargin{i+1};
        case 'dopermnonsig'
            doPermNonsig = varargin{i+1};
        case 'dopermsig'
            doPermSig = varargin{i+1};
        case 'donumbers'
            doNumbers = varargin{i+1};
        case 'dojoints'
            doJoints = varargin{i+1};
    end
end
% --------------------------------------------------
% Define colormaps for F and T images
CMap.F = load('colormap_roma.mat');
CMap.F = CMap.F.roma(128:end, :);
CMap.T = load('colormap_roma.mat');
CMap.T = CMap.T.roma;
% --------------------------------------------------
% Make figures of the design matrix and the topographic surface
plotDesignMatrix(GLM);
plotSurface(GLM.surface, GLM.chanlocs, [], [], false, fullfile(fileparts(GLM.filepath), 'images', 'surface.png'));
% --------------------------------------------------
% Plot topoplots for each F and T test
for i = 1:length(GLM.result)
    if isfield(GLM.result(i), 'f')
        for j = 1:length(GLM.result(i).f)
            switch GLM.poststats.Method
                case {'ClusterMass', 'ClusterExtent'}
                    p_cor = GLM.result(i).f(j).p_perm;
                    t_cor = GLM.poststats.ClusterAlpha;
                case 'TFCE'
                    p_cor = GLM.result(i).f(j).p_perm;
                    t_cor = GLM.poststats.ChanWiseAlpha;
                case 'FDR'
                    p_cor = GLM.result(i).f(j).p_fdr;
                    t_cor = GLM.poststats.ChanWiseAlpha;
                otherwise
                    p_cor = ones(size(GLM.result(i).f(j).p_unc));
                    t_cor = GLM.poststats.ChanWiseAlpha;
            end
            p_unc = GLM.result(i).f(j).p_unc;
            t_unc = GLM.poststats.ChanWiseAlpha;
            H = plotGroupStatTopoplot(...
                [], ...
                GLM.result(i).f(j).stat, ...
                p_unc, ...
                p_cor, ...
                t_unc, ...
                t_cor, ...
                GLM.chanlocs, ...
                GLM.surface, ...
                'clusters', GLM.result(i).f(j).cluster, ...
                'FigPosition', [50 50 255 255], ...
                'Colormap', CMap.F, ...
                'CBarLabel', 'F statistic', ...
                'CLim', [0, Inf], ...
                'doSave', true, ...
                'doUnc', doUnc, ...
                'doPermNonsig', doPermNonsig, ...
                'doPermSig', doPermSig, ...
                'doNumbers', doNumbers, ...
                'doJoints', doJoints, ...
                'outpath', fullfile(fileparts(GLM.filepath), 'images', sprintf('result_f_m%i_c%i.png', i, j)));
            close all
        end
    end
    for j = 1:length(GLM.result(i).t)
        % ID #0014
        switch GLM.poststats.Method
            case {'ClusterMass', 'ClusterExtent'}
                p_cor = GLM.result(i).t(j).p_perm;
                t_cor = GLM.poststats.ClusterAlpha;
            case 'TFCE'
                p_cor = GLM.result(i).t(j).p_perm;
                t_cor = GLM.poststats.ChanWiseAlpha;
            case 'FDR'
                p_cor = GLM.result(i).t(j).p_fdr;
                t_cor = GLM.poststats.ChanWiseAlpha;
            otherwise
                p_cor = ones(size(GLM.result(i).t(j).cope));
                t_cor = 0.05.*ones(size(GLM.result(i).t(j).cope));
        end
        p_unc = GLM.result(i).t(j).p_unc;
        t_unc = GLM.poststats.ChanWiseAlpha;
        H = plotGroupStatTopoplot(...
            GLM.result(i).t(j).cope, ...
            GLM.result(i).t(j).stat, ...
            p_unc, ...
            p_cor, ...
            t_unc, ...
            t_cor, ...
            GLM.chanlocs, ...
            GLM.surface, ...
            'clusters', GLM.result(i).t(j).cluster, ...
            'FigPosition', [50 50 510 255], ...
            'Colormap', CMap.T, ...
            'CBarLabel', 'T statistic', ...
            'CLim', [-3.1, 3.1], ...
            'doSave', true, ...
            'doUnc', doUnc, ...
            'doPermNonsig', doPermNonsig, ...
            'doPermSig', doPermSig, ...
            'doNumbers', doNumbers, ...
            'doJoints', doJoints, ...
            'outpath', fullfile(fileparts(GLM.filepath), 'images', sprintf('result_t_m%i_c%i.png', i, j)));
        close all
    end
end

close all

end