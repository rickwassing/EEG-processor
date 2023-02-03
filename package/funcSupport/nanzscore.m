function x = nanzscore(x)
x = bsxfun(@rdivide, bsxfun(@minus, x, mean(x, 'omitnan')), std(x, 'omitnan'));
end