function [chanlocs, ndchanlocs] = template_to_chanlocs(FullFilePath)

urchanlocs = readlocs(FullFilePath);

for ch = 1:length(urchanlocs)
    if ...
            strcmp(urchanlocs(ch).labels(1), 'E') || ...
            strcmp(urchanlocs(ch).labels, 'Cz') || ...
            regexpIdx(FullFilePath, 'Compumedics-257') || ...
            regexpIdx(FullFilePath, 'Ten-Twenty') || ...
            regexpIdx(FullFilePath, 'Grael')
        urchanlocs(ch).type = 'EEG';
    else
        urchanlocs(ch).type = 'FID';
    end
end

idxEEG = strcmp({urchanlocs.type}, 'EEG');

chanlocs = urchanlocs(idxEEG);
ndchanlocs = urchanlocs(~idxEEG);

end