function [name, ext, pathstr] = reverse_fileparts(file)

[pathstr, name, ext] = fileparts(file);

end