% Copyrights by Christine Blume
% https://github.com/ChristineBlume/SleepCycles

function periods = find_remperiods(score, remp_length)

if ~any(size(score)) == 1
    error('Input must be a vector')
end

if size(score, 2) == 1
    score = score';
end

rem_epochs = find(score == 5);

if isempty(rem_epochs)
    periods = [];
    return
end

rem_start = rem_epochs(1);

% Check if the sequence of min. 10 REM epochs is continuous
for k = 1:length(rem_epochs)-remp_length-1
    if all((rem_epochs(k):rem_epochs(k)+remp_length-1) == rem_epochs(k:k+remp_length-1))
        rem_start = [rem_start, rem_epochs(k)]; %#ok<AGROW>
    end
end
rem_start = unique(rem_start);

% find discontinuities in the sequence (= potential beginnings of new NREM period further into the night)
periods = rem_start(1);

if length(rem_start) == 1
    return
end

for k = 1:length(rem_start)-1
    if (rem_start(k+1) - rem_start(k)) > 1
        periods = [periods, rem_start(k+1)]; % if there is an discontinuity in the sequence, mark the beginning of a new REM period
    end
end

end