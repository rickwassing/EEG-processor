function [D, levels, refGrp] = codeDummyVar(X, varargin)
% Make sure X is a row vector
if ~any(size(X)) == 1
    error('Input X must be a vector')
end
if size(X, 2) ~= 1
    X = X';
end
% Make sure X is categorical
if ~iscategorical(X)
    X = categorical(X);
end
% Get the levels in X
levels = asrow(unique(X(~ismissing(X)), 'stable'));
% Get which type of dummy coding to do
if nargin > 2
    type = varargin{2};
else
    type = 'sigma';
end
% Get the reference group
if nargin > 1
    refGrp = varargin{1};
    if isempty(refGrp)
        refGrp = levels(1);
    end
else
    refGrp = levels(1);
end
% Remove the ref-group from 'levels'
if ~strcmpi(type, 'cell')
    levels(levels == refGrp) = [];
end
% Translate to dummy variables
D = zeros(length(X), length(levels));
% For each remaining level, set their indices to '1'
for i = 1:length(levels)
    D(X == levels(i), i) = 1;
    if strcmpi(type, 'sigma')
        D(X == refGrp, i) = -1;
    end
end
% Convert to cell strings
refGrp = char(refGrp);
levels = cellstr(levels);
% Add missing values
D(ismissing(X), :) = NaN;

end