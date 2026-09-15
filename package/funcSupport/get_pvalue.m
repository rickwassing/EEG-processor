function [stat, pval] = get_pvalue(settings, prefix, statToken, type, unit, modality, design, contrast)
switch type
    case 'p_unc'
        pType = 'uncp';
    case 'p_fwe'
        pType = 'fwep';
    case 'p_fdr'
        pType = 'fdrp';
    case 'p_perm'
        pType = 'fwep';
    otherwise
        error('type is not supported')
end

outputDir = fullfile(settings.OutputDir, 'output');
fnameStat = find_palm_output(outputDir, prefix, statToken, ...
    modality, design, contrast, unit);
fnameP = find_palm_output(outputDir, prefix, ...
    sprintf('%s_%s', statToken, pType), modality, design, contrast, unit);
stat = asrow(readmatrix(fnameStat, 'Delimiter', ','));
pval = asrow(readmatrix(fnameP, 'Delimiter', ','));
end
