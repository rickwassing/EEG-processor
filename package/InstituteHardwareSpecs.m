function Specs = InstituteHardwareSpecs(DataType)
% ---------------------------------------------------------
% Specify the institute and hardware specficications
Specs = struct();
Specs.InstitutionName = 'Woolcock Institute of Medical Research';
Specs.InstitutionAddress = '431 Glebe Point Road, Glebe NSW 2037, Australia';
switch DataType
    case 'MFF'
        Specs.Manufacturer  = 'Electrical Geodesics, Inc.';
        Specs.ManufacturersModelName  = 'NetAmps 400';
        Specs.SoftwareVersions = 'NetStation Acquisition v5.4.2 (r29917)';
        Specs.HardwareFilters = 'n/a';
    case 'COMPU257'
        Specs.Manufacturer  = 'Compumedics Neuroscan';
        Specs.ManufacturersModelName  = 'Neuvo amplifier';
        Specs.SoftwareVersions = 'Profusion EEG v6.1 build 1793';
        Specs.HardwareFilters = 'n/a';
    otherwise
        Specs.Manufacturer  = 'Electrical Geodesics, Inc.';
        Specs.ManufacturersModelName  = 'NetAmps 400';
        Specs.SoftwareVersions = 'NetStation Acquisition v5.4.2 (r29917)';
        Specs.HardwareFilters = 'n/a';
end
end