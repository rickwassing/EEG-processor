% PRINTERRORMESSAGE
% Prints an error message to the command window in red text and provides a
% link to the online bug report form.

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-03-17, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function printerrormessage(ME, varargin)

url = sprintf('https://docs.google.com/forms/d/e/1FAIpQLScmkJhc2FPKjyNVHeR3SL29qGqrS8pyWb1Jy2Iw1jI9ZLKJLA/viewform?usp=pp_url&entry.165730575=%s', urlencode(getReport(ME, 'extended','hyperlinks', 'off')));

fprintf('\n');
fprintf(2, '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n');
fprintf(2, 'Oh no! An error. How embarrassing. <a href="%s">Please click here to submit a bug report</a>.\n', url);
fprintf(2, '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
fprintf(2, 'Error message:\n');
fprintf(2, getReport(ME));
fprintf('\n');
if nargin > 1
    fprintf('\n');
    for i = 1:length(varargin)
        fprintf(2, '%s\n', varargin{i})
    end
end
fprintf(2, '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n');
fprintf('\n');
end