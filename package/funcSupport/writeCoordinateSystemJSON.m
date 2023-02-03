function writeCoordinateSystemJSON(EEG, CoordFilename)

Coord = struct();
Coord.EEGCoordinateSystem = 'EEGLAB';
Coord.EEGCoordinateUnits = 'cm';
Coord.EEGCoordinateSystemDescription = 'X-axis towards anterior, Y-axis towards left, Z-axis towards superior';
if isfield(EEG.chaninfo, 'ndchanlocs')
    for i = 1:length(EEG.chaninfo.ndchanlocs)
        switch EEG.chaninfo.ndchanlocs(i).labels
            case 'FidNz'
                label = 'NAS';
            case 'FidT9'
                label = 'LPA';
            case 'FidT10'
                label = 'RPA';
            otherwise
                label = EEG.chaninfo.ndchanlocs(i).labels;
        end
        Coord.AnatomicalLandmarkCoordinates.(label) = [ ...
            EEG.chaninfo.ndchanlocs(i).X, ...
            EEG.chaninfo.ndchanlocs(i).Y, ...
            EEG.chaninfo.ndchanlocs(i).Z, ...
            ];
    end
end
if isfield(EEG.chaninfo, 'ndchanlocs')
    if ~isempty(EEG.chaninfo.ndchanlocs)
        Coord.AnatomicalLandmarkCoordinateSystem = 'EEGLAB';
        Coord.AnatomicalLandmarkCoordinateUnits = 'cm';
        Coord.AnatomicalLandmarkCoordinateSystemDescription	= 'Location of the electrodes at the nasion (NAS), at the left preauricular (LPA), and the right preauricular (RPA)';
    end
end
struct2json(Coord, CoordFilename);

end