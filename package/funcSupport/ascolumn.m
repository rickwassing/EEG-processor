function v = ascolumn(v)
if isempty(v)
    return
end
if ~(any(size(v) == 1))
    error('Input needs to be a vector')
end
if isrow(v)
    v = v';
end
end