function y = map(x,min_map,max_map,min_x,max_x)

if nargin == 3
    min_x = min(x(:));
    max_x = max(x(:));
end

x(x > max_x) = max_x;
x(x < min_x) = min_x;

y = ((x - min_x) ./ (max_x - min_x)) .* (max_map - min_map) + min_map;

end