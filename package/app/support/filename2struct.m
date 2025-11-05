function S = filename2struct(Filename)

S = struct();

C = cellfun(@(str) strsplit(str, '-'), strsplit(Filename, '_'), 'UniformOutput', false);

for i = 1:length(C)
    if numel(C{i}) > 1
        S.(C{i}{1}) = C{i}{2};
    else
        S.filetype = C{i}{1};
    end
end

end