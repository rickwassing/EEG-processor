function EEG = storeHistory(EEG, funcName, Settings)
% -------------------------------------------------------------------------
% Extract all the settings from the structure
History = 'Settings';
History = getFields(Settings, History);
% -------------------------------------------------------------------------
% Create the code to reproduce this step
History = char(...
    '%%% ==================================================', ...
    ['%%% ', sprintf('Call to ''%s'' (%s)',funcName, datestr(now, 'dd-mm-yyyy HH:MM:SS'))], ...
    '% ----------------------------------------------------', ...
    '% Specify settings', ...
    History, ...
    '% ----------------------------------------------------', ...
    '% Call function', ...
    sprintf('EEG = %s(Settings);', funcName));
% -------------------------------------------------------------------------
% Append to the file's history
if ~isfield(EEG, 'history')
    EEG.history = '';
end

try
    h = splitlines(EEG.history);
    EEG.history = char(h{:}, History);
catch ME
    printME(ME);
end

    % ---------------------------------------------------------------------
    % SUB FUNCTION
    function r = isexempt(fname)
        switch fname
            case 'Header'
                r = true;
            case 'Chanlocs'
                r = true;
            case 'MinRecDuration'
                r = true;
            case 'MinSamplingFreq'
                r = true;
            case 'AllEvents'
                r = true;
            case 'CommonEventLabels'
                r = true;
            case 'editable'
                r = true;
            case 'EEG'
                r = true;
            case 'PSD'
                r = true;
            case 'MarkerSize'
                r = true;
            case 'Threshold'
                r = true;
            case 'InputRatio'
                r = true;
            case 'LogTransData'
                r = true;
            case 'SelChan'
                r = true;
            case 'Legend'
                r = true;
            case 'TopoChanlocs'
                r = true;
            case 'nTrials'
                r = true;
            case 'HasICA'
                r = true;
            otherwise
                r = false;
        end
    end
    % ---------------------------------------------------------------------
    % SUB FUNCTION
    function L = getFields(S, l)
        if isstruct(S)
            f = fieldnames(S);
            L = '';
            for i = 1:length(f)
                if isexempt(f{i})
                    continue
                end
                if length(S) == 1
                    tmp = [l, '.', f{i}];
                    tmp = getFields(S.(f{i}), tmp);
                    if isempty(L)
                        L = tmp;
                    else
                        L = char(L, tmp);
                    end
                else
                    for j = 1:length(S)
                        tmp = [l, '(', num2str(j),')', '.', f{i}];
                        tmp = getFields(S(j).(f{i}), tmp);
                        if isempty(L)
                            L = tmp;
                        else
                            L = char(L, tmp);
                        end
                    end
                end
            end
        else
            L = [l, ' = ', getValues(S, true)];
        end
    end
    % ---------------------------------------------------------------------
    % SUB FUNCTION
    function v = getValues(S, doSuppress)
        v = '';
        if iscell(S) && length(S) > 1
            v = '{';
            for i = 1:length(S)
                if size(S, 1) == 1
                    v = [v, getValues(S{i}, false), ', ']; %#ok<AGROW> 
                else
                    v = [v, getValues(S{i}, false), '; ']; %#ok<AGROW> 
                end
            end
            try
            v(end-1:end) = [];
            catch
                keyboard
            end
            v = [v, '}'];
        elseif isnumeric(S) && length(S) > 1
            v = '[';
            for i = 1:length(S)
                if size(S, 1) == 1
                    v = [v, getValues(S(i), false), ', ']; %#ok<AGROW> 
                else
                    v = [v, getValues(S(i), false), '; ']; %#ok<AGROW> 
                end
            end
            v(end-1:end) = [];
            v = [v, ']'];
        elseif isempty(S) && iscell(S)
            v = '{}';
        elseif isempty(S) && isnumeric(S)
            v = '[]';
        elseif isempty(S) && islogical(S)
            v = '[]';
        elseif isempty(S) && ischar(S)
            v = '''''';
        elseif isempty(S) && isstring(S)
            v = '''''';
        elseif ischar(S)
            v = sprintf('''%s''', S);
        elseif isnumeric(S) 
            if mod(S, 1) < 10e-6 
                v = sprintf('%i', S); % is integer
            else
                v = sprintf('%.8f', S); % Float
            end
        elseif islogical(S)
            if S
                v = 'true';
            else
                v = 'false';
            end
        end
        if doSuppress
            v = [v, ';'];
        end
    end

end