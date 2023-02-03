function hasErrors = CreateBIDSDirectories(app)

hasErrors = false;

if exist('./sourcedata', 'dir') == 0
    [status, cmdout] = system('mkdir sourcedata');
    if status ~= 0
        hasErrors = true;
        sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when setting up the BIDS database. Nothing is loaded.', cmdout}, 'Error', ...
            'Options',{'Ok'},...
            'DefaultOption', 'Ok', ...
            'Icon', 'error'); %#ok<NASGU>
        return
    end
end
if exist('./rawdata', 'dir') == 0
    [status, cmdout] = system('mkdir rawdata');
    if status ~= 0
        hasErrors = true;
        sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when setting up the BIDS database. Nothing is loaded.', cmdout}, 'Error', ...
            'Options',{'Ok'},...
            'DefaultOption', 'Ok', ...
            'Icon', 'error'); %#ok<NASGU>
        return
    end
end
if exist('./derivatives', 'dir') == 0
    [status, cmdout] = system('mkdir derivatives');
    if status ~= 0
        hasErrors = true;
        sel = uiconfirm(app.UIFigure, {'Sorry, an unexpected error occurred when setting up the BIDS database. Nothing is loaded.', cmdout}, 'Error', ...
            'Options',{'Ok'},...
            'DefaultOption', 'Ok', ...
            'Icon', 'error'); %#ok<NASGU>
        return
    end
end

end