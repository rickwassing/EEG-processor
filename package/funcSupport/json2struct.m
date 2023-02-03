function s = json2struct(fullfilepath)

s = jsondecode(fileread(fullfilepath));

end

