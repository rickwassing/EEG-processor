function chanlocs = channel_clusters(chanlocs, DataType)

switch DataType
    case 'MFF'
        clusters = readtable('egi256_clusters.csv');
    case 'COMPU257'
        clusters = readtable('neuvo256_clusters.csv');
    otherwise
        for i = 1:length(chanlocs)
            if ~strcmpi(chanlocs(i).type, 'EEG')
                continue
            end
            chanlocs(i).cluster = 1;
        end
        return
end

for i = 1:length(chanlocs)
    idx = strcmpi(chanlocs(i).labels, clusters.chan);
    chanlocs(i).cluster = clusters.cluster(idx);
end
