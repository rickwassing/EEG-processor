function Filename = struct2filename(KeyVals)

Filename = cellfun(@(key, val) [key, '-', val], fieldnames(KeyVals), struct2cell(KeyVals), 'UniformOutput', false);
Filename = [strjoin(Filename(1:end-1), '_'), '_', KeyVals.filetype];

end