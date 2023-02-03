function C = get_cluster(p_clust, a_thres, surface, chanlocs)
% Init
C = struct([]);
% Get significant channels
SigChans = find(p_clust < 1);
% If there are no significant channels, then return
if isempty(SigChans)
    return
end
% Create adjacency matrix of significant channels
AMat = false(size(surface.Points, 1), size(surface.Points, 1));
for k = 1:size(surface.ConnectivityList, 1)
    if ismember(surface.ConnectivityList(k, 1), SigChans) && ismember(surface.ConnectivityList(k, 2), SigChans)
        AMat(surface.ConnectivityList(k, 1), surface.ConnectivityList(k, 2)) = true;
    end
    if ismember(surface.ConnectivityList(k, 1), SigChans) && ismember(surface.ConnectivityList(k, 3), SigChans)
        AMat(surface.ConnectivityList(k, 1), surface.ConnectivityList(k, 3)) = true;
    end
    if ismember(surface.ConnectivityList(k, 2), SigChans) && ismember(surface.ConnectivityList(k, 3), SigChans)
        AMat(surface.ConnectivityList(k, 2), surface.ConnectivityList(k, 3)) = true;
    end
end
% Initialize nodes
SigNodes = 1:size(surface.Points, 1);
% Make matrix bi-directional
AMat = AMat | AMat';
% Remove all channels that are not connected to any other significant channel
rm = sum(AMat) == 0;
AMat(rm, :) = [];
AMat(:, rm) = [];
SigNodes(rm) = [];
% Get the clusters from the graph
[Clusters, ClustSize] = conncomp(graph(AMat));
for c = 1:max(Clusters)
    if length(unique(p_clust(SigNodes(Clusters == c)))) > 1
        error('More than one unique p-value for this cluster')
    end
    C(c).chanlocs = chanlocs(SigNodes(Clusters == c));
    C(c).size = ClustSize(c);
    C(c).p_clust = max(p_clust(SigNodes(Clusters == c)));
    C(c).issig = C(c).p_clust <= a_thres;
end
if max(Clusters) > 0
    % Order by size
    [~, idx] = sort([C.p_clust]);
    C = C(idx);
end
end