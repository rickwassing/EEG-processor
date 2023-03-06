function duration = str2duration(str)

str = strsplit(str, ' ');
duration = 0;
for i = 1:length(str)
    if strcmpi(str{i}(end-1:end), 'ms')
        duration = duration + str2double(str{i}(1:end-2))/(24*60*60*1000);
        continue
    end
    switch str{i}(end)
        case 'd'
            duration = duration + str2double(str{i}(1:end-1));
        case 'h'
            duration = duration + str2double(str{i}(1:end-1))/(24);
        case 'm'
            duration = duration + str2double(str{i}(1:end-1))/(24*60);
        case 's'
            duration = duration + str2double(str{i}(1:end-1))/(24*60*60);
        otherwise
            error('Unit ''%s'' is not supported', str{i}(end))
    end
end

end