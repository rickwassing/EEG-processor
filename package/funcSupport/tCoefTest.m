function [p, T] = tCoefTest(mdl, c)

T = (c*mdl.Coefficients.Estimate)/(sqrt(c*mdl.CoefficientCovariance*c'));
p = tcdf(abs(T), mdl.DFE, 'upper')*2;

end