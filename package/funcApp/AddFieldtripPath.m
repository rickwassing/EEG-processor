function AddFieldtripPath(app)

KnownFieldtripLocs = { ...
    'S:\Sleep\SleepSoftware\fieldtrip\latest';
    };

fieldtripDir = fileparts(which('ft_defaults'));
if ~isempty(fieldtripDir)
    % Assume fieldtrip is already added to the path
    return
else
    for i = 1:length(KnownFieldtripLocs)
        if exist([KnownFieldtripLocs{i}, '/', 'ft_defaults.m'], 'file')
            fieldtripDir = KnownFieldtripLocs{i};
            break
        end
    end
end
if ~isempty(fieldtripDir)
    addpath(fieldtripDir);
    ft_defaults
else
    sel = uiconfirm(app.UIFigure, 'Fieldtrip is not added to the Matlab path. Please use the browse button to specify the path where ''ft_defaults.m'' is located', 'Question', ...
        'Options',{'Browse'},...
        'DefaultOption', 'Browse', ...
        'Icon', 'question'); %#ok<NASGU>
    fieldtripDir = uigetdir('.', 'Specify the path where ''ft_defaults.m'' is located');
    if fieldtripDir == 0 % User pressed cancel, so quit
        sel = uiconfirm(app.UIFigure, 'You pressed ''Cancel'', so I quit.', 'Info', ...
            'Options',{'Quit'},...
            'DefaultOption', 'Quit', ...
            'Icon', 'Info'); %#ok<NASGU>
        delete(app);
        return
    end
    if exist([fieldtripDir, '/ft_defaults.m'], 'file') == 0
        sel = uiconfirm(app.UIFigure, ['''ft_defaults.m'' is not located in ''', fieldtripDir,''', so I quit.'], 'Info', ...
            'Options',{'Quit'},...
            'DefaultOption', 'Quit', ...
            'Icon', 'Info'); %#ok<NASGU>
        delete(app);
        return
    else
        addpath(fieldtripDir);
        ft_defaults;
    end
end
end