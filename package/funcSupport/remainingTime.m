function T = remainingTime(T, N)
% REMAININGTIME Display the progress and remaining time for loops
if ~isstruct(T)
    t = T;
    T = struct();
    T.startTime = t;
    T.cnt = 0;
    T.str = '';
    fprintf('Start date: %s - ',datestr(T.startTime,'dd/mm/yyyy HH:MM:SS'))
end

T.cnt = T.cnt + 1;

rt = ((now - T.startTime)/T.cnt)*(N-T.cnt);
HH = floor(rt*24);
MM = floor((rt*24-HH)*60);
SS = floor(((rt*24-HH)*60-MM)*60);
rt = [addLeadingZero(num2str(HH)) ':' addLeadingZero(num2str(MM)) ':' addLeadingZero(num2str(SS))];
pct = floor(100*(T.cnt/N));

fprintf([repmat('\b', 1, length(T.str)) '(%.0f%%) %s '], pct, rt)

T.str = sprintf('(%.0f%%) %s ', pct, rt);

if T.cnt == N
    fprintf('- Finished in %s\n', datestr(now-T.startTime, 'HH:MM:SS'))
    T = now;
end

    function str = addLeadingZero(str)
        if numel(str) == 1
            str = ['0', str];
        end
    end

end
