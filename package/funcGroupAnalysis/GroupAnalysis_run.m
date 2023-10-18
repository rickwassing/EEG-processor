function [Data, Next, Warnings] = GroupAnalysis_run(app, Settings) %#ok<INUSL> 
% ==================================================
% RUN PALM
% See for more details, see
% 'https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM/UserGuide'
% 'https://neuroconductor.org/help/freesurferformats/'
% 'http://eeg.sourceforge.net/doc_m2html/bioelectromagnetism/freesurfer_read_surf.html#_subfunctions'
% 'http://www.grahamwideman.com/gw/brain/fs/surfacefileformats.htm'
% 'https://www.mail-archive.com/freesurfer@nmr.mgh.harvard.edu/msg07901.html'
% 'https://au.mathworks.com/help/matlab/math/delaunay-triangulation.html'
Data = [];
Next = '';
Warnings = [];
doRun = true;
overwriteSeed = nan;
% --------------------------------------------------
% Extract the design matrix
if ~isfield(Settings, 'result')
    switch Settings.ModelType
        case 'Two-sample paired t-test'
            Intercept = [];
        case 'General Linear Model'
            if contains(Settings.Model.ModelSpec, '~ 1')
                Intercept = ones(size(Settings.Input, 1), 1);
            else
                Intercept = [];
            end
        otherwise
            Intercept = ones(size(Settings.Input, 1), 1);
    end
    DesMat = [Intercept, ...
        [Settings.Model.Predictors.DesMat], ...
        [Settings.Model.Interactions.DesMat], ...
        [Settings.Model.RandVars.DesMat]];
    % --------------------------------------------------
    % Deal with missing data
    Missing = sum(isnan(DesMat), 2) > 0;
    if any(Missing)
        Settings.Input(Missing, :) = [];
        Settings.Model.ExchangeabilityBlocks(Missing) = [];
        Settings.Model.VarianceGroups(Missing) = [];
        for i = 1:length(Settings.Model.Predictors)
            Settings.Model.Predictors(i).DesMat(Missing, :) = [];
        end
        for i = 1:length(Settings.Model.Interactions)
            Settings.Model.Interactions(i).DesMat(Missing, :) = [];
        end
        for i = 1:length(Settings.Model.RandVars)
            Settings.Model.RandVars(i).DesMat(Missing, :) = [];
        end
    end
else
    switch Settings.modeltype
        case 'Two-sample paired t-test'
            Intercept = [];
        case 'General Linear Model'
            if contains(Settings.model.ModelSpec, '~ 1 +')
                Intercept = ones(size(Settings.input, 1), 1);
            else
                Intercept = [];
            end
        otherwise
            Intercept = ones(size(Settings.input, 1), 1);
    end
    DesMat = [Intercept, ...
        [Settings.model.Predictors.DesMat], ...
        [Settings.model.Interactions.DesMat], ...
        [Settings.model.RandVars.DesMat]];
end
% --------------------------------------------------
% Map some code so we can run this function using the 'GLM' output variable
if isfield(Settings, 'result')
    GLM = Settings;
    Settings = struct();
    Settings.OutputDir = fileparts(GLM.filepath);
    Settings.Chanlocs = GLM.chanlocs;
    Settings.Input = GLM.input;
    Settings.ModelType = GLM.modeltype;
    Settings.Model = GLM.model;
    Settings.Statistics = GLM.stats;
    Settings.PostStats = GLM.poststats;
else
    % --------------------------------------------------
    % Init the output structure
    GLM = struct();
    GLM.filepath = fullfile(Settings.OutputDir, 'glm.mat');
    GLM.command = '';
    if isnan(overwriteSeed)
        GLM.seed = round((now() - datenum('2023-01-01'))*24*60*60); %#ok<DATNM,TNOW1>
    else
        GLM.seed = overwriteSeed;
    end
    GLM.chanlocs = Settings.Chanlocs;
    GLM.inputfiletype = Settings.Input.KeyVals{1}.filetype;
    GLM.input = Settings.Input;
    GLM.modeltype = Settings.ModelType;
    GLM.model = Settings.Model;
    GLM.stats = Settings.Statistics;
    GLM.poststats = Settings.PostStats;
end
% --------------------------------------------------
% Read all input data files
Data = struct();
for i = 1:size(GLM.input, 1)
    Data(i).EEG = LoadDataset(GLM.input.Path{i}, 'all');
end
% --------------------------------------------------
% Depending on the type of input file, extract the dependent variable
DepVars = struct();
switch GLM.inputfiletype
    case 'powerspect'
        % Find which frequency bands were common across all files
        if any(arrayfun(@(d) size(d.EEG.bands(1).data, 2), Data) > 1)
            fprintf('>> BIDS: **************************************************\n')
            fprintf('>> BIDS: WARNING\n')
            fprintf('>> BIDS: Group-level analysis on data with more than 1 trial is not yet supported.\n')
            fprintf('>> BIDS: The PSD values will be averaged across trials.\n')
            fprintf('>> BIDS: **************************************************\n')
        end
        types = {Data(1).EEG.bands.type};
        bands = {Data(1).EEG.bands.label};
        labels = cellfun(@(t, b) [t, ' ', b], types, bands, 'UniformOutput', false);
        for i = 2:length(Data)
            this_labels = cellfun(@(t, b) [t, ' ', b], {Data(i).EEG.bands.type}, {Data(i).EEG.bands.label}, 'UniformOutput', false);
            labels = labels(ismember(labels, this_labels));
        end
        % Extract the dependent variable matrix for each frequency band
        for i = 1:length(labels)
            DepVars(i).label = labels{i};
            tmp = arrayfun(@(d) mean(d.EEG.bands(i).data, 2), Data, 'UniformOutput', false);
            if contains(labels{i}, 'absolute')
                DepVars(i).value = log2(cat(2, tmp{:}))';
            else
                DepVars(i).value = cat(2, tmp{:})';
            end
        end
end
% --------------------------------------------------
% Extract EB and VG
EB = Settings.Model.ExchangeabilityBlocks;
VG = Settings.Model.VarianceGroups;
% --------------------------------------------------
% Construct all the T-contrast matrices
Tcons = struct([]);
for i = 1:size(Settings.Statistics.Ttests.Contrasts, 1)
    Tcons(i).Title = Settings.Statistics.Ttests.Titles{i};
    Tcons(i).Sided = Settings.Statistics.Ttests.Sided{i};
    Tcons(i).Mat = Settings.Statistics.Ttests.Contrasts(i, :);
end
% --------------------------------------------------
% Screen out any F-test on only one T-contrast, these F-tests are not run because they are the same as t-contrasts
% This section, however, should be obsolete because this is already screened for in the GUI
rm_idx = sum(Settings.Statistics.Ftests) == 1;
Settings.Statistics.Ftests(:, rm_idx) = [];
% --------------------------------------------------
% Extract F-contrasts
T_FTESTS = GLM.stats.Ttests.Contrasts; % This orig T-contrast matrix is used for F-tests only
F = Settings.Statistics.Ftests;
% --------------------------------------------------
% Create subdir if not exist yet
InputFileDir = [Settings.OutputDir, filesep, 'input'];
OutputFileDir = [Settings.OutputDir, filesep, 'output'];
if exist(InputFileDir, 'dir') == 0
    if ispc
        [status, cmdout] = system(['mkdir "', InputFileDir, '"']);
    else
        [status, cmdout] = system(['mkdir -p "', InputFileDir, '"']);
    end
    if status ~= 0
        error(cmdout);
    end
end
if exist(OutputFileDir, 'dir') == 0
    if ispc
        [status, cmdout] = system(['mkdir "', OutputFileDir, '"']);
    else
        [status, cmdout] = system(['mkdir -p "', OutputFileDir, '"']);
    end
    if status ~= 0
        error(cmdout);
    end
end
% --------------------------------------------------
% Create surface file from channel locations
writelocs(Settings.Chanlocs, fullfile(InputFileDir, 'chanlocs.sfp'), 'filetype', 'xyz');
GLM.surface = chanlocs2surface(...
    fullfile(InputFileDir, 'surface.srf'), ...
    fullfile(InputFileDir, 'chanlocs.sfp'), false, false);
% --------------------------------------------------
% Write the design matrix, and T and F constrasts to csv files
writematrix(DesMat, fullfile(InputFileDir, 'desmat.csv'));
for i = 1:length(Tcons)
    writematrix(Tcons(i).Mat, fullfile(InputFileDir, sprintf('tcontrast%i.csv', i)));
end
writematrix(EB, fullfile(InputFileDir, 'exchangeability_blocks.csv'));
writematrix(VG, fullfile(InputFileDir, 'variance_groups.csv'));
if ~isempty(F)
    writematrix(T_FTESTS, fullfile(InputFileDir, 'tcontrasts_ftests.csv'));
    writematrix(F', fullfile(InputFileDir, 'ftests.csv')); % F-matrix should be transposed
end
% --------------------------------------------------
% Create the parameter structure from which we can generate the PALM commands
params = struct();
% Seed for random generator
params.seed = sprintf('-seed %i ', GLM.seed);
% --------------------------------------------------
% For each dependent variable...
params.in = '';
for i = 1:length(DepVars)
    % --------------------------------------------------
    % Write the data to csv file which are used by PALM as input
    writematrix(DepVars(i).value, fullfile(InputFileDir, sprintf('depvar_%i.csv', i)));
    % --------------------------------------------------
    % Specify the input files
    params.in = [params.in, sprintf('-i ''%s'' ', fullfile(InputFileDir, sprintf('depvar_%i.csv', i)))];
end
% --------------------------------------------------
% Specify the option parameters
% --------------------------------------------------
% Surface, design matrix ex-blocks, var-groups
params.s = sprintf('-s ''%s'' ', fullfile(InputFileDir, 'surface.srf'));
params.d = sprintf('-d ''%s'' ', fullfile(InputFileDir, 'desmat.csv'));
params.eb = sprintf('-eb ''%s'' ', fullfile(InputFileDir, 'exchangeability_blocks.csv'));
params.vg = sprintf('-vg ''%s'' ', fullfile(InputFileDir, 'variance_groups.csv'));
% --------------------------------------------------
% T-contrast input files
params.t = struct([]);
for i = 1:length(Tcons)
    params.t(i).arg = sprintf('-t ''%s'' ', fullfile(InputFileDir, sprintf('tcontrast%i.csv', i)));
end
% --------------------------------------------------
% F-tests input files
params.t_f = '';
params.f = '';
if ~isempty(F)
    params.t_f = sprintf('-t ''%s'' ', fullfile(InputFileDir, 'tcontrasts_ftests.csv'));
    params.f = sprintf('-f ''%s'' ', fullfile(InputFileDir, 'ftests.csv'));
end
% --------------------------------------------------
% Output prefix
for i = 1:length(Tcons)
    params.o_t(i).arg = sprintf('-o ''%s'' ', fullfile(OutputFileDir, sprintf('palm_tstat%i', i)));
end
params.o_f = '';
if ~isempty(F)
    params.o_f = sprintf('-o ''%s'' ', fullfile(OutputFileDir, 'palm_fstat'));
end
% --------------------------------------------------
% Number of permutations, and sign-flips
params.n = sprintf('-n %i ', Settings.PostStats.NumPermutations);
params.ee = ifelse(Settings.PostStats.DoPermutations, '-ee ', '');
params.ise = ifelse(Settings.PostStats.DoSignFlips, '-ise ', '');
% --------------------------------------------------
% Cluster-forming method, and TFCE parameters
params.Cstat ='';
params.tfce = '';
params.tfce_H = '';
params.tfce_E = '';
params.tfce_C = '';
switch Settings.PostStats.Method
    case 'ClusterExtent'
        params.Cstat = '-Cstat extent ';
    case 'ClusterMass'
        params.Cstat = '-Cstat mass ';
    case 'TFCE'
        params.tfce = '-T ';
        params.tfce_H = sprintf('-tfce_H %.2f ', Settings.PostStats.TFCE_H);
        params.tfce_E = sprintf('-tfce_E %.2f ', Settings.PostStats.TFCE_E);
        params.tfce_C = '-tfce_C 6 ';
end
% --------------------------------------------------
% Cluster-forming threshold
params.C_t = struct([]);
% Set argument
switch Settings.PostStats.Method
    case {'ClusterExtent', 'ClusterMass'}
        for i = 1:length(Tcons)
            Sided = ifelse(strcmpi(Tcons(i).Sided, 'two'), 2, 1);
            params.C_t(i).arg = sprintf('-C %.6f ', norminv(1-Settings.PostStats.ChanWiseAlpha/Sided));
        end
    otherwise
        for i = 1:length(Tcons)
            params.C_t(i).arg = '';
        end
end
params.C_f = '';
if ~isempty(F)
    params.C_f = sprintf('-C %.6f ', norminv(1-Settings.PostStats.ChanWiseAlpha/Sided));
end
% --------------------------------------------------
% FDR
params.fdr = ifelse(strcmpi(Settings.PostStats.Method, 'FDR'), '-fdr ', '');
% --------------------------------------------------
% Permute within and between blocks
params.within = ifelse(Settings.PostStats.PermWithin, '-within ', '');
params.whole = ifelse(Settings.PostStats.PermWhole, '-whole ', '');
% --------------------------------------------------
% Saving and verbose
params.savedof = '-savedof ';
params.savemetrics = '-savemetrics ';
params.saveglm = '-saveglm ';
params.verbose = '-verbosefilenames ';
params.quiet = '-quiet ';
% --------------------------------------------------
% Create the commands for t-contrasts and f-tests and execute!
for i = 1:length(Tcons)
    switch Tcons(i).Sided
        case 'one'
            params.twotail = '';
        case 'two'
            params.twotail = '-twotail ';
    end
    cmd = ['palm ', ...
        params.in, ...
        params.s, ...
        params.d, ...
        params.eb, ...
        params.vg, ...
        params.t(i).arg, ...
        params.o_t(i).arg, ...
        params.n, ...
        params.ee, ...
        params.ise, ...
        params.fdr, ...
        params.Cstat, ...
        params.C_t(i).arg, ...
        params.tfce, ...
        params.tfce_H, ...
        params.tfce_E, ...
        params.tfce_C, ...
        params.within, ...
        params.whole, ...
        params.twotail, ...
        params.seed, ...
        params.savedof, ...
        params.savemetrics, ...
        params.saveglm, ...
        params.verbose, ...
        params.quiet];
    % Store command
    GLM.command = char(GLM.command, cmd);
    % RUN!
    fprintf('>> BIDS: Running PALM on T-contrast %i of %i\n', i, length(Tcons));
    if doRun; eval(cmd); end
end

% Create the command for f-tests and execute!
if ~isempty(params.f)
    cmd = ['palm ', ...
        params.in, ...
        params.s, ...
        params.d, ...
        params.eb, ...
        params.vg, ...
        params.t_f, ...
        params.f, ...
        params.o_f, ...
        params.n, ...
        params.ee, ...
        params.ise, ...
        params.fdr, ...
        params.C_f, ...
        params.Cstat, ...
        params.tfce, ...
        params.tfce_H, ...
        params.tfce_E, ...
        params.tfce_C, ...
        params.within, ...
        params.whole, ...
        params.seed, ...
        params.savedof, ...
        params.savemetrics, ...
        params.verbose, ...
        params.quiet, ...
        '-fonly'];
    % Store command
    GLM.command = char(GLM.command, cmd);
    % RUN!
    fprintf('>> BIDS: Running PALM on F-tests\n');
    if doRun; eval(cmd); end
end
% --------------------------------------------------
% Load the permutation metrics
mfiles = dir(fullfile(OutputFileDir, 'palm_*stat*_d1_c*_metrics.csv'));
GLM.poststats.MaxPermutations = Inf;
for i = 1:length(mfiles)
    tmp = readtable(fullfile(mfiles(i).folder, mfiles(i).name), 'NumHeaderLines', 0);
    if ~any(strcmpi(tmp.Properties.VariableNames, 'Var2'))
        continue
    end
    if exp(tmp.Var2(1)) < GLM.poststats.MaxPermutations
        GLM.poststats.MaxPermutations = exp(tmp.Var2(1));
    end
end
% --------------------------------------------------
% Init the output fields
GLM.data = DepVars;
% Check what value is given as the 'unit' key in the filename
switch Settings.PostStats.Method
    case {'Uncorrected', 'FDR'}
        unit = 'dat';
    otherwise
        unit = 'dpv';
end
GLM.result = struct();
for i = 1:length(GLM.data)
    % --------------------------------------------------
    % Enter the label and initialize the tables
    GLM.result(i).label = GLM.data(i).label;
    GLM.result(i).t = struct();
    % --------------------------------------------------
    % For each t-contrast, extract the statistics and p-values
    for j = 1:length(Tcons)
        % --------------------------------------------------
        % Extract the title
        GLM.result(i).t(j).title = Tcons(j).Title;
        % --------------------------------------------------
        % Save the Cohen's D statistic
        fname = fullfile(OutputFileDir, sprintf('palm_tstat%i_%s_cohen_m%i_d1_c1.csv', j, unit, i));
        GLM.result(i).t(j).cohen = asrow(readmatrix(fname, 'Delimiter', ','));
        % --------------------------------------------------
        % Save the contrast of parameter estimates
        fname = fullfile(OutputFileDir, sprintf('palm_tstat%i_%s_cope_m%i_d1_c1.csv', j, unit, i));
        GLM.result(i).t(j).cope = asrow(readmatrix(fname, 'Delimiter', ','));
        % --------------------------------------------------
        % Save the variance of the constrast of parameter estimates
        fname = fullfile(OutputFileDir, sprintf('palm_tstat%i_%s_varcope_m%i_d1_c1.csv', j, unit, i));
        GLM.result(i).t(j).varcope = asrow(readmatrix(fname, 'Delimiter', ','));
        % --------------------------------------------------
        % Save the t-statistic
        Stat = 'T';
        fname = fullfile(OutputFileDir, sprintf('palm_tstat%i_%s_tstat_m%i_d1_c1.csv', j, unit, i));
        if exist(fname, 'file') == 0
            Stat = 'V';
            fname = fullfile(OutputFileDir, sprintf('palm_tstat%i_%s_vstat_m%i_d1_c1.csv', j, unit, i));
        end
        GLM.result(i).t(j).stat = asrow(readmatrix(fname, 'Delimiter', ','));
        % --------------------------------------------------
        % Save the uncorrected p-value
        [~, GLM.result(i).t(j).p_unc] = get_pvalue(Settings, Stat, 'p_unc', unit, i, j);
        % --------------------------------------------------
        % Save the FWE corrected p-value
        [~, GLM.result(i).t(j).p_fwe] = get_pvalue(Settings, Stat, 'p_fwe', unit, i, j);
        % --------------------------------------------------
        % Save the permutation corrected p-value
        switch GLM.poststats.Method
            case 'TFCE'
                [GLM.result(i).t(j).t_perm, GLM.result(i).t(j).p_perm] = get_pvalue(Settings, Stat, 'p_fwe', 'tfce', i, j);
                GLM.result(i).t(j).p_fdr = NaN;
                GLM.result(i).t(j).cluster = struct([]);
            case 'ClusterMass'
                [GLM.result(i).t(j).t_perm, GLM.result(i).t(j).p_perm] = get_pvalue(Settings, Stat, 'p_fwe', 'clusterm', i, j);
                GLM.result(i).t(j).p_fdr = NaN;
                GLM.result(i).t(j).cluster = get_cluster(...
                    GLM.result(i).t(j).t_perm, ...
                    GLM.result(i).t(j).p_perm, ...
                    GLM.poststats.ClusterAlpha, ...
                    GLM.surface, ...
                    GLM.chanlocs);
            case 'ClusterExtent'
                [GLM.result(i).t(j).t_perm, GLM.result(i).t(j).p_perm] = get_pvalue(Settings, Stat, 'p_fwe', 'clustere', i, j);
                GLM.result(i).t(j).p_fdr = NaN;
                GLM.result(i).t(j).cluster = get_cluster(...
                    GLM.result(i).t(j).t_perm, ...
                    GLM.result(i).t(j).p_perm, ...
                    GLM.poststats.ClusterAlpha, ...
                    GLM.surface, ...
                    GLM.chanlocs);
            case 'FDR'
                GLM.result(i).t(j).t_perm = NaN;
                GLM.result(i).t(j).p_perm = NaN;
                [~, GLM.result(i).t(j).p_fdr] = get_pvalue(Settings, Stat, 'p_fdr', 'dat', i, j);
                GLM.result(i).t(j).cluster = struct([]);
            otherwise
                GLM.result(i).t(j).t_perm = NaN;
                GLM.result(i).t(j).p_perm = NaN;
                GLM.result(i).t(j).p_fdr = NaN;
                GLM.result(i).t(j).cluster = struct([]);
        end
    end
    % --------------------------------------------------
    % For each f-contrast, extract the statistics and p-values
    for j = 1:size(GLM.stats.Ftests, 2)
        % --------------------------------------------------
        % Extract the title
        GLM.result(i).f(j).title = sprintf('F%i', j);
        % --------------------------------------------------
        % Save the z-statistic
        fname = fullfile(OutputFileDir, sprintf('palm_fstat_%s_fstat_m%i_d1_c%i.csv', unit, i, j));
        GLM.result(i).f(j).stat = asrow(readmatrix(fname, 'Delimiter', ','));
        % --------------------------------------------------
        % Save the uncorrected p-value
        [~, GLM.result(i).f(j).p_unc] = get_pvalue(Settings, 'F', 'p_unc', unit, i, j);
        % --------------------------------------------------
        % Save the FWE corrected p-value
        [~, GLM.result(i).f(j).p_fwe] = get_pvalue(Settings, 'F', 'p_fwe', unit, i, j);
        % --------------------------------------------------
        % Save the permutation corrected p-value
        switch Settings.PostStats.Method
            case 'TFCE'
                [GLM.result(i).f(j).f_perm, GLM.result(i).f(j).p_perm] = get_pvalue(Settings, 'F', 'p_fwe', 'tfce', i, j);
                GLM.result(i).f(j).p_fdr = NaN;
                GLM.result(i).f(j).cluster = struct([]);
            case 'ClusterMass'
                [GLM.result(i).f(j).f_perm, GLM.result(i).f(j).p_perm] = get_pvalue(Settings, 'F', 'p_fwe', 'clusterm', i, j);
                GLM.result(i).f(j).p_fdr = NaN;
                GLM.result(i).f(j).cluster = get_cluster(...
                    GLM.result(i).f(j).f_perm, ...
                    GLM.result(i).f(j).p_perm, ...
                    GLM.poststats.ClusterAlpha, ...
                    GLM.surface, ...
                    GLM.chanlocs);
            case 'ClusterExtent'
                [GLM.result(i).f(j).f_perm, GLM.result(i).f(j).p_perm] = get_pvalue(Settings, 'F', 'p_fwe', 'clustere', i, j);
                GLM.result(i).f(j).p_fdr = NaN;
                GLM.result(i).f(j).cluster = get_cluster(...
                    GLM.result(i).f(j).f_perm, ...
                    GLM.result(i).f(j).p_perm, ...
                    GLM.poststats.ClusterAlpha, ...
                    GLM.surface, ...
                    GLM.chanlocs);
            case 'FDR'
                GLM.result(i).f(j).f_perm = NaN;
                GLM.result(i).f(j).p_perm = NaN;
                [~, GLM.result(i).f(j).p_fdr] = get_pvalue(Settings, 'F', 'p_fdr', 'dat', i, j);
                GLM.result(i).f(j).cluster = struct([]);
            otherwise
                GLM.result(i).f(j).f_perm = NaN;
                GLM.result(i).f(j).p_perm = NaN;
                GLM.result(i).f(j).p_fdr = NaN;
                GLM.result(i).f(j).cluster = struct([]);
        end
    end
end
% --------------------------------------------------
% Make the mat file, the figures and the HTML report and open it in the browser
save(GLM.filepath, 'GLM', '-v7.3');
if doRun; GroupAnalysis_plot(GLM); end
GroupAnalysis_htmlreport(GLM);

end
