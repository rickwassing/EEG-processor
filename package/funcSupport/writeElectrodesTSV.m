function writeElectrodesTSV(EEG, ElectrodesFilename)

Electrodes = table();
Electrodes.name = ascolumn({EEG.chanlocs.labels});
Electrodes.x = ascolumn({EEG.chanlocs.X});
Electrodes.y = ascolumn({EEG.chanlocs.Y});
Electrodes.z = ascolumn({EEG.chanlocs.Z});

Electrodes.x(cellfun(@(val) isempty(val), Electrodes.x, 'UniformOutput', true)) = {'n/a'};
Electrodes.y(cellfun(@(val) isempty(val), Electrodes.y, 'UniformOutput', true)) = {'n/a'};
Electrodes.z(cellfun(@(val) isempty(val), Electrodes.z, 'UniformOutput', true)) = {'n/a'};

writetable(Electrodes, ElectrodesFilename, 'FileType', 'text', 'Delimiter', '\t');

end