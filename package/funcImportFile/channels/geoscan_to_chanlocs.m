function [chanlocs, ndchanlocs] = geoscan_to_chanlocs(meta_file)
    
    coordinates = readtable(meta_file);
    coordinates.Properties.VariableNames = {'labels', 'x', 'y', 'z', 'estimated'};
    
    % Coordinates are re-oriented to fit the EEGLAB standard of having the nose along the +X axis.
    % That is why the Y coordinate replaces the X coordinate and vice versa.
    % Also, check if the Y coordinates should be reversed

    % Fixed ID #0012
    sfp = [(1:size(coordinates))', -1.*coordinates.y, coordinates.x, coordinates.z]; 
    
    save('temp.sfp', 'sfp', '-ascii', '-tabs')
    if exist('temp.sfp', 'file') == 0
        error('Unexpected error while saving temporary channel file')
    end
    urchanlocs = readlocs('temp.sfp');
    delete('temp.sfp')
    
    % reorder fieldnames, as sometimes this is mixed up
    urchanlocs = orderfields(urchanlocs, {...
        'labels', ...
        'X', ...
        'Y', ...
        'Z', ...
        'sph_theta', ...
        'sph_phi', ...
        'sph_radius', ...
        'theta', ...
        'radius', ...
        'sph_theta_besa', ...
        'sph_phi_besa'});
    
    for ch = 1:length(urchanlocs)
        urchanlocs(ch).Y = urchanlocs(ch).Y;
        urchanlocs(ch).labels = coordinates.labels{ch};
        if ...
            strcmp(coordinates.labels{ch}(1), 'E') || ...
            strcmp(coordinates.labels{ch}, 'Cz')
            urchanlocs(ch).type = 'EEG';
        else
            urchanlocs(ch).type = 'FID';
        end
    end
    
    idxEEG = strcmp({urchanlocs.type}, 'EEG');
    
    chanlocs = urchanlocs(idxEEG);
    ndchanlocs = urchanlocs(~idxEEG);
    
end