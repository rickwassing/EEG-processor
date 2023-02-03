function [z,mu,sigma] = nonparzscore(x,flag,dim)
%ZSCORE Non-parametric standardized z score.
%   Z = NONPARZSCORE(X) returns a centered, scaled version of X, the same size as X.
%   For vector input X, Z is the vector of z-scores (X-MEDIAN(X)) ./ MAD(X). For
%   matrix X, z-scores are computed using the median and median absolute deviation
%   along each column of X.  For higher-dimensional arrays, z-scores are
%   computed using the median and median absolute deviation along the first
%   non-singleton dimension.
%
%   The columns of Z have sample median zero and sample median absolute deviation one
%   (unless a column of X is constant, in which case that column of Z is
%   constant at 0).
%
%   [Z,MU,SIGMA] = NONPARZSCORE(X) also returns MEDIAN(X) in MU and MAD(X) in SIGMA.
%
%   [...] = NONPARZSCORE(X,1) normalizes X using MAD(X,1), i.e., by computing the
%   MAD based on medians, i.e. MEDIAN(ABS(X-MEDIAN(X)) instead of MEAN(ABS(X-MEDIAN(X)).
%   ZSCORE(X,0) is the same as ZSCORE(X).
%
%   [...] = ZSCORE(X,FLAG,'all') standardizes X by working on all the
%   elements of X. 
%
%   [...] = ZSCORE(X,FLAG,DIM) standardizes X by working along the dimension
%   DIM of X.
%
%   [...] = ZSCORE(X,FLAG,VECDIM) standardizes X by working along the all the
%   dimensions of X specified in VECDIM.
%
%   See also MEDIAN, MAD.

%   Adapted from ZSCORE by Rick Wassing (rickwassing@gmail.com) on 30/01/2021. 


% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = x; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Validate flag
if ~(isequal(flag,0) || isequal(flag,1) || isempty(flag))
    error(message('stats:trimmean:BadFlagReduction'));
end

% Compute X's median and mad, and standardize it
mu = median(x,dim);
sigma = mad(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);

end