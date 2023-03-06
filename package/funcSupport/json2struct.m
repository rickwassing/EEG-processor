function s = json2struct(fullfilepath)
s = fileread(fullfilepath);
s = strrep(s, '\', '/');
s = jsondecode(s);
end

