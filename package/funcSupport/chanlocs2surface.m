function DT = chanlocs2surface(filepath, chanlocs, doPlot, do3d)
% --------------------------------------------------
% Code adapted from
% https://www.mail-archive.com/freesurfer@nmr.mgh.harvard.edu/msg07901.html

% ==================================================
% Calculate vertices and faces from channel locations
% NOTE! RAS Coordinate system: X = left-right, Y = Post-Ant, and Z = Inf-Sup
% NOTE! Coordinates must be in millimeters
% NOTE! Vertex ID is a zero-based index
% NOTE! Faces must be defined by the vertices anti-clockwise, see
% http://eeg.sourceforge.net/doc_m2html/bioelectromagnetism/freesurfer_read_surf.html#_subfunctions
% ==================================================

% --------------------------------------------------
% Default constant
nVerticesPerFace = 3;
% --------------------------------------------------
% First get the 2D representation of the channel locations
[chanlocs, ~, Th, Rd] = readlocs(chanlocs);
Th = pi/180*Th; % convert to radians
% Convert the polar coordinates to cartesian coordinates
% Note that X and Y are swapped to adhere to the RAS coordinate system
[y, x] = pol2cart(Th, Rd);
% --------------------------------------------------
% Calculate the triangulation of the 2D points. This creates a set of faces
% each specified by 3 vertices accroding to Delaunay's algorithm. See, for
% more info:
% https://au.mathworks.com/help/matlab/math/delaunay-triangulation.html
DT = delaunayTriangulation(x', y');
% --------------------------------------------------
% Plot if requested
if doPlot
    plotSurface(DT, chanlocs, x, y, do3d)
end
% --------------------------------------------------
% Open file for writing
fid = fopen(filepath, 'w');
% --------------------------------------------------
% Check if file-id is valid
if fid == -1
    error('Could not open file %s', filepath)
end
% --------------------------------------------------
% Write header lines, specify number of vertices and faces
fprintf(fid, '#!ascii version of EEG channel locations\n');
fprintf(fid, '%d %d\n', length(chanlocs), size(DT.ConnectivityList, 1));
% --------------------------------------------------
% For each vertex...
for i = 1:length(chanlocs)
    % ... Write X, Y, and Z coordinates to file (in millimeters)
    fprintf(fid, '%.3f %.3f %.3f 1\n', chanlocs(i).Y*10, chanlocs(i).X*10, chanlocs(i).Z*10);
end
% --------------------------------------------------
% For each face...
for i = 1:size(DT.ConnectivityList, 1)
    % ... Write list of this face's vertices to file
    if nVerticesPerFace == 3
        % Note, subtract 1 for zero-based indexing
        fprintf(fid, '%d %d %d 1\n', DT.ConnectivityList(i, 1)-1, DT.ConnectivityList(i, 2)-1, DT.ConnectivityList(i, 3)-1);
    else
        error('Number of vertices per face is not supported')
    end
end
% --------------------------------------------------
% Close the file
fclose(fid);

end