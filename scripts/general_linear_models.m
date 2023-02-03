% =========================================================================
% Init
clc
clear
close all
doSigmaResCoding = true;

% =========================================================================
% Load and process example data
load carbig
load examgrades
when = cellstr(when);
org = cellstr(org);
% -------------------------------------------------------------------------
% Construct two-level table
idx = ~strcmpi(when, 'Mid');
TWO = table();
TWO.Y = MPG(idx)+rand(sum(idx), 1)*500;
TWO.A = categorical(when(idx));
TWO.C = Cylinders(idx);
TWO(isnan(TWO.Y), :) = [];
% -------------------------------------------------------------------------
% Construct paired table
PAIRED = table();
PAIRED.Y = [grades(:, 1); grades(:, 2)];
PAIRED.A = [zeros(size(grades, 1), 1);ones(size(grades, 1), 1)];
PAIRED.P = [(1:size(grades, 1))';(1:size(grades, 1))'];
% -------------------------------------------------------------------------
% Contruct one-way anova three-level table
ONEWAY = table();
ONEWAY.Y = MPG+rand(size(MPG, 1), 1)*500;
ONEWAY.A = categorical(when);
ONEWAY.B = categorical(org);
ONEWAY.C = Cylinders;
ONEWAY(isnan(ONEWAY.Y), :) = [];
% -------------------------------------------------------------------------
% Contruct two-way anova two- three-level table
idx = ~strcmpi(org, 'Japan');
TWOWAY = table();
TWOWAY.Y = MPG(idx)+rand(sum(idx), 1)*500;
TWOWAY.A = categorical(when(idx));
TWOWAY.B = categorical(org(idx));
TWOWAY.C = Cylinders(idx);
TWOWAY(isnan(TWOWAY.Y), :) = [];

% =========================================================================
% Correlation
% -------------------------------------------------------------------------
% Remove one of the three levels to compare just the two groups
t = TWO;
% -------------------------------------------------------------------------
% Design matrix
X = [t.C];
% -------------------------------------------------------------------------
% Contrasts
c = [0, 1];
% -------------------------------------------------------------------------
% Fit
mdl = fitlm(X, t.Y);
[p, F] = coefTest(mdl, c);
fprintf('==============================================================\n')
fprintf('Correlation\n')
fprintf('Stat = %.4f p = %.5g\n', F, p);
% =========================================================================
% Two sample unpaired t-test
% -------------------------------------------------------------------------
% Remove one of the three levels to compare just the two groups
t = TWO;
% -------------------------------------------------------------------------
% Design matrix
D = codeDummyVar(t.A, 'Late', 'Treatment');
X = [D];
% -------------------------------------------------------------------------
% Contrasts
c = [0, 1];
% -------------------------------------------------------------------------
% Fit
mdl = fitlm(X, t.Y);
[p, F] = coefTest(mdl, c);
fprintf('==============================================================\n')
fprintf('Two sample unpaired t-test\n')
fprintf('Stat = %.4f p = %.5g\n', F, p);

% =========================================================================
% Two sample paired t-test
% -------------------------------------------------------------------------
% Remove one of the three levels to compare just the two groups
t = PAIRED;
% -------------------------------------------------------------------------
% Design matrix
D = codeDummyVar(t.A, '1', 'Sigma');
P = codeDummyVar(t.P, [], 'Cell');
X = [D, P];
% -------------------------------------------------------------------------
% Contrasts
c = [1, zeros(1, size(P, 2))];
% -------------------------------------------------------------------------
% Fit
mdl = fitlm(X, t.Y, 'Intercept', false);
[p, F] = coefTest(mdl, c);
fprintf('==============================================================\n')
fprintf('Two sample paired t-test\n')
fprintf('Stat = %.4f p = %.5g\n', F, p);

%% =========================================================================
% One-way ANOVA (1 factor, 3 levels)
% -------------------------------------------------------------------------
% Remove one of the three levels to compare just the two groups
clc
t = ONEWAY;
% -------------------------------------------------------------------------
% Design matrix
D = codeDummyVar(t.A, 'Early', 'Sigma');
X = [D];
% -------------------------------------------------------------------------
% Contrasts


C = struct();
C(1).Name = 'Main effect';
C(1).c = [0, 1, 0; 0, 0, 1];
C(2).Name = 'Early > Mid';
C(2).c = [1 1 0] - [1 -1 -1];
C(3).Name = 'Early > Late';
C(3).c = [1 0 1] - [1 -1 -1];
C(4).Name = 'Mid > Late';
C(4).c = [1 0 1] - [1 1 0];
% -------------------------------------------------------------------------
% Fit
mdl = fitlm(X, t.Y);
fprintf('==============================================================\n')
fprintf('One-way ANOVA (1 factor, 3 levels)\n')
for i = 1:length(C)
    [p, F] = coefTest(mdl, C(i).c);
    fprintf('%s. Stat = %.4f p = %.5g\n', C(i).Name, F, p);
end
mdl = fitlm(t, 'Y ~ 1 + A')
anova(mdl, 'component', 3)
%% =========================================================================
% One-way ANOVA (1 factor, 4 levels)
% -------------------------------------------------------------------------
% Remove one of the three levels to compare just the two groups
clc
t = ONEWAY;
t.A(100:150) = {'Now'};
% -------------------------------------------------------------------------
% Design matrix
D = codeDummyVar(t.A, 'Early', 'Sigma');
X = [D];
% -------------------------------------------------------------------------
% Contrasts
c = {[0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1], [0, 2, 1, 1; 0, 1, 2, 1; 0, 1, 1, 2], [0 2 1 1], [0 1 2 1], [0 1 1 2]};
% -------------------------------------------------------------------------
% Fit
mdl = fitlm(X, t.Y);
fprintf('==============================================================\n')
fprintf('One-way ANOVA (1 factor, 4 levels)\n')
for i = 1:length(c)
    [p, F] = coefTest(mdl, c{i});
    fprintf('Stat = %.4f p = %.5g\n', F, p);
end
mdl = fitlm(t, 'Y ~ 1 + A')
anova(mdl, 'component', 3)
%% =========================================================================
% Two-way ANOVA (2 factor, 2 and 3 levels)
% -------------------------------------------------------------------------
% Remove one of the three levels to compare just the two groups
t = TWOWAY;
% -------------------------------------------------------------------------
% Design matrix
A = codeDummyVar(t.A, 'Early', 'Sigma');
B = codeDummyVar(t.B, 'Europe', 'Sigma');
I = codeInterxVars(A, B);
X = [A, B, I];
% -------------------------------------------------------------------------
% Contrasts
c = {[0, 1, 0, 0, 0, 0; 0, 0, 1, 0, 0, 0], [0 0 0 1 0 0], [0 2 1 0 0 0], [0 0 0 1 -1 -1]};
% -------------------------------------------------------------------------
% Fit
mdl = fitlm(X, t.Y);
fprintf('==============================================================\n')
fprintf('Two-way ANOVA (2 factor, 2 and 3 levels)\n')
for i = 1:length(c)
    [p, F] = coefTest(mdl, c{i});
    fprintf('Stat = %.4f p = %.5g\n', F, p);
end

%% 

rm_idx = strcmpi(when, 'Early');
MPG = MPG(~rm_idx);
when = when(~rm_idx);
org = org(~rm_idx);

[p, tbl] = anovan(MPG,{org when},...
    'model', 'interaction',...
    'varnames',{'A','B'}, ...
    'display','off');
disp(tbl)
TWO = table();
idx = ~isnan(MPG);
TWO.MPG = MPG;
TWO.A = categorical(org);
TWO.B = categorical(when);
TWO = TWO(idx,:);
mdl = fitlm(TWO, 'MPG ~ 1 + A*B');
anova(mdl, 'component', 3)

A = dummyvar(TWO.A);
if doSigmaResCoding
    for c = 2:size(A, 2)
        A(A(:, 1) == 1, c) = -1;
    end
end
B = dummyvar(TWO.B);
if doSigmaResCoding
    for c = 2:size(B, 2)
        B(B(:, 1) == 1, c) = -1;
    end
end
X = [ones(size(TWO.A)), A(:, 2:end), B(:, 2:end)];
for i = 2:size(A, 2)
    for j = 2:size(B, 2)
        X = [X, A(:, i).*B(:, j)];
    end
end

check = fitlm(X(:,2:end), TWO.MPG);
[p, F] = coefTest(check, [0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1]);
fprintf('F = %.5f p = %.5g\n', F, p)

%%
clc
load popcorn

TWO = table();
TWO.popcorn = sort(popcorn(:));
TWO.A = categorical(repmat([1; 1; 1; 2; 2; 2; 3; 3; 3], 2, 1));
TWO.B = categorical([ones(9, 1);ones(9, 1)*2]);

% Remove one case
TWO(18,:) = [];

mdl = fitlm(TWO, 'popcorn ~ 1 + A*B');
anovan(mdl)
% [p, F] = coefTest(mdl, [0 2 0 0 1 0; 0 0 2 0 0 1]);
% fprintf('A, F = %.3f p = %.3g\n', F, p)
% [p, F] = coefTest(mdl, [0 0 0 3 1 1]);
% fprintf('B, F = %.3f p = %.3g\n', F, p)

A = dummyvar(TWO.A);
A(A(:, 1) == 1, 2) = -1;
A(A(:, 1) == 1, 3) = -1;
B = dummyvar(TWO.B);
B(B(:, 1) == 1, 2) = -1;
X = [ones(size(TWO.A)), A(:, 2:end), B(:, 2:end)];
X = [X, X(:, 2).*X(:, 4), X(:, 3).*X(:, 4)];

C = doolittleWeights(X);
check = fitlm(X(:,2:end), TWO.popcorn);
[p, F] = coefTest(check, C([2 3], :));
fprintf('A, F = %.5f p = %.5g\n', F, p)
% [p, F] = coefTest(check, [0 0 1 0 0 0]);
% fprintf('B, F = %.3f p = %.3g\n', F, p)

%% 

close all

Fig = figure();
Ax = axes();
Ax.NextPlot = 'add';
Ax.XLim = [0 3*2+1];
Ax.YLim = [0 max(TWO.popcorn)+1];
b = mdl.Coefficients.Estimate;
x = 0;
for a = 1:3
    for b = 1:2
        idx = TWO.A == categorical(a) & TWO.B == categorical(b);
        if b == 1
            clr = 'sr';
        else
            clr = 'sb';
        end
        x = x+1;
        plot(Ax, x+linspace(-0.1, 0.1, sum(idx)), TWO.popcorn(idx), clr)
    end
end

b = mdl.Coefficients.Estimate;
plot(Ax, Ax.XLim, [b(1), b(1)], '-r')
plot(Ax, [3, 3], [b(1), b(1)+b(2)], '-r')
plot(Ax, [5, 5], [b(1), b(1)+b(3)], '-r')
plot(Ax, [2, 2], [b(1), b(1)+b(4)], '-b')
plot(Ax, [4, 4], [b(1)+b(2), b(1)+b(2)+b(4)], '-b')
plot(Ax, [4.1, 4.1], [b(1)+b(2)+b(4), b(1)+b(2)+b(4)+b(5)], '-m')
plot(Ax, [6, 6], [b(1)+b(3), b(1)+b(3)+b(4)], '-b')
plot(Ax, [6.1, 6.1], [b(1)+b(3)+b(4), b(1)+b(3)+b(4)+b(6)], '-m')


