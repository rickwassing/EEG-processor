function pval = get_pvalue(settings, stat, type, u, m, c)
switch type
    case 'p_unc'
        p_type = 'uncp';
    case 'p_fwe'
        p_type = 'fwep';
    case 'p_fdr'
        p_type = 'fdrp';
    case 'p_perm'
        p_type = 'fwep';
    otherwise
        error('type is not supported')
end
switch stat
    case 'F'
        fname_p = fullfile(settings.OutputDir, 'output', sprintf('palm_fstat_%s_fstat_%s_m%i_d1_c%i.csv', u, p_type, m, c));
        pval = asrow(readmatrix(fname_p, 'Delimiter', ','));
    case 'T'
        fname_p = fullfile(settings.OutputDir, 'output', sprintf('palm_tstat%i_%s_tstat_%s_m%i_d1_c1.csv', c, u, p_type, m));
        pval = asrow(readmatrix(fname_p, 'Delimiter', ','));
end
end
