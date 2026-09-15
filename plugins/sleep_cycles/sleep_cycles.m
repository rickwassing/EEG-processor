% Copyrights by Christine Blume
% https://github.com/ChristineBlume/SleepCycles

function C = sleep_cycles(stages, definition, varargin)

% check input
if ~any(size(stages)) == 1
    error('Input ''stage_num'' must be a vector')
end
if ~any(size(definition)) == 1
    error('Input ''definition'' must be a vector')
end
if length(definition) ~= 5
    error('Input ''definition'' must contain 5 elements. An integer or character that denotes each sleep stage (wake, N1, N2, N3, and REM).')
end
if ...
        (iscell(stages) && ~iscell(definition)) || ...
        (~iscell(stages) && iscell(definition)) || ...
        (isnumeric(stages) && ~isnumeric(definition)) || ...
        (~isnumeric(stages) && isnumeric(definition))
    error('Inputs ''stage_num'' and ''definition'' must be the same class.')
end

% force row vectors
if size(stages, 2) == 1; stages     = stages';     end
if size(definition, 2) == 1; definition = definition'; end

% translate the stages
stages_num = nan(1, length(stages));
if iscell(stages)
    stages_num(strcmp(stages, definition{1})) = 0; % Wake
    stages_num(strcmp(stages, definition{2})) = 1; % N1
    stages_num(strcmp(stages, definition{3})) = 2; % N2
    stages_num(strcmp(stages, definition{4})) = 3; % N3
    stages_num(strcmp(stages, definition{5})) = 5; % REM
elseif isnumeric(stages)
    stages_num(stages == definition(1)) = 0; % Wake
    stages_num(stages == definition(2)) = 1; % Wake
    stages_num(stages == definition(3)) = 2; % Wake
    stages_num(stages == definition(4)) = 3; % Wake
    stages_num(stages == definition(5)) = 5; % Wake
end


% Options
sleep_start = 'n1';
remp_length = 10; % in epochs

% Score is a vector where
% 5: REM
% 3: NREM-3
% 2: NREM-2
% 1: NREM-1
% 0: Wake

nrem_wake_epochs = find(stages_num <= 3);
nrem_epochs = find(stages_num == 1 | stages_num == 2 | stages_num == 3);
first_n2_epoch = find(stages_num == 2, 1, 'first');
first_rem_epoch = find(stages_num == 5, 1, 'first');

% Deal with the edge case where a REM epoch is score before a NREM one
if first_rem_epoch < nrem_epochs(1)
    error('REM sleep is scored before any NREM epoch, I can''t deal with this')
end

switch lower(sleep_start)
    case 'n1'
        nrem_wake_epochs = nrem_wake_epochs(nrem_epochs(1):end);
    case 'n2'
        nrem_wake_epochs = nrem_wake_epochs(first_n2_epoch:end);
    otherwise
        error('The option ''SleepStart'' must be ''n1'' or ''n2''.')
end

% Check if the sequence of nrem_wake_epochs is continuous and the period is
% >=15 min AND beginning is not wake -> first NREM period.
nrem_periods = find_nremperiods(nrem_wake_epochs, stages_num);
rem_periods = find_remperiods(stages_num, remp_length);

cycles = table();
cycles.epoch = [nrem_periods';rem_periods'];
cycles.desc = [...
    repmat({'nremp'}, length(nrem_periods), 1); ...
    repmat({'remp'}, length(rem_periods), 1)];
[~, idx] = sort(cycles.epoch);
cycles = cycles(idx, :);

% NREM and REM periods should be alternating, remove doubles
rm = [];
for k = 2:size(cycles, 1)
    if strcmpi(cycles.desc{k-1}, cycles.desc{k})
        rm = [rm, k]; %#ok<AGROW> 
    end
end
cycles(rm, :) = [];

% Split NREM periods if longer than 120 minutes (excl wake epochs)
curr_size = 0;
it = 0;
while size(cycles, 1) ~= curr_size && it < 10
    it = it + 1;
    curr_size = size(cycles, 1);
    cycles = split_toolong(stages_num, cycles);
end

% Add the cycle number
c = 1;
for i = 1:size(cycles, 1)
    if i > 1
        if strcmpi(cycles.desc{i-1}, 'remp')
            c = c+1;
        end
        if strcmpi(cycles.desc{i-1}, 'nremp') && strcmpi(cycles.desc(i), cycles.desc(i-1))
            c = c+1;
        end
    end
    cycles.cycle(i) = c;
end

% Get the end of the last period
switch cycles.desc{end}
    case 'nremp'
        stop = find(stages_num == 1 | stages_num == 2 | stages_num == 3);
        stop(stop < cycles.epoch(end)) = [];
        stop = max(stop);
    case 'remp'
        stop = find(stages_num == 5);
        stop(stop < cycles.epoch(end)) = [];
        stop = max(stop);
end
c = table();
c.epoch = stop;
c.desc = 'stop';
c.cycle = max(cycles.cycle);
cycles = [cycles; c];

C = struct();
C.times = (0:30/(60*60*24):(length(stages_num)-1)*(30/(60*60*24)));
C.sleepstage = nan(size(stages_num));
C.sleepstage(stages_num == 0) = 1;
C.sleepstage(stages_num == 1) = -1;
C.sleepstage(stages_num == 2) = -2;
C.sleepstage(stages_num == 3) = -3;
C.sleepstage(stages_num == 5) = 0;
C.sleepcycle = nan(size(stages_num));
C.sleepepisode = nan(size(stages_num));
for i = 1:max(cycles.cycle)
    % Start and stop of this cycle
    start = min(cycles.epoch(cycles.cycle == i));
    stop = min(cycles.epoch(cycles.cycle == i+1))-1;
    if isempty(stop)
        stop = cycles.epoch(end);
    end
    % Start and stop of descending, sws, ascending and REM sleep.
    rem_start = cycles.epoch(cycles.cycle == i & strcmpi(cycles.desc, 'remp'));
    sws_epoch = find(stages_num == 3);
    sws_epoch(sws_epoch < start | sws_epoch > stop) = [];
    if ~isempty(sws_epoch)
        sws_start = min(sws_epoch);
        sws_stop = max(sws_epoch);
    else
        sws_start = start + round((rem_start - start)/2);
        sws_stop = start + round((rem_start - start)/2) - 1;
    end
    C.sleepcycle(start:stop) = i;
    C.sleepepisode(start:sws_start-1) = -1;
    C.sleepepisode(sws_start:sws_stop) = -2;
    C.sleepepisode(sws_stop+1:rem_start-1) = 1;
    C.sleepepisode(rem_start:stop) = 2;
end

end