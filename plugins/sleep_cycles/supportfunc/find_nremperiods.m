% Copyrights by Christine Blume
% https://github.com/ChristineBlume/SleepCycles

function periods = find_nremperiods(nrem_wake_epochs, score)

if ~any(size(nrem_wake_epochs)) == 1
    error('Input must be a vector')
end

if size(nrem_wake_epochs, 2) == 1
    nrem_wake_epochs = nrem_wake_epochs';
end

% Check if the sequence of NREWM is continuous AND the period is >= 15min AND beginning is not wake
nrem_wake_start = [];
for k = 1:length(nrem_wake_epochs)-29
    if all((nrem_wake_epochs(k):nrem_wake_epochs(k)+29) == nrem_wake_epochs(k:k+29)) && score(nrem_wake_epochs(k)) ~= 0
        nrem_wake_start = [nrem_wake_start, nrem_wake_epochs(k)]; %#ok<AGROW> 
    end
end
if isempty(nrem_wake_start)
    periods = [];
    return
end
% find discontinuities in the sequence (= potential beginnings of new NREM period further into the night)
periods = nrem_wake_start(1);
for k = 1:length(nrem_wake_start)-1
    if nrem_wake_start(k+1) - nrem_wake_start(k) > 1 % there is a discontinuity in the sequence
        periods = [periods, nrem_wake_start(k+1)]; %#ok<AGROW> 
    end
end


end