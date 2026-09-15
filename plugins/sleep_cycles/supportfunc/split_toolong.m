function cycles = split_toolong(score, cycles)

too_long = find_toolong(score, cycles);

for i = 1:length(too_long)

    % Begin and end index of this too-long period
    beg_end = [cycles.epoch(too_long(i)), cycles.epoch(too_long(i)+1)];

    % Find RWN12 episodes that are > 12min within detected NREMP -> "lightening of sleep" = potential splitting points
    RWN12s = find(score == 0 | score == 1 | score == 2 | score == 5); % which  epochs are R, W, or N1/2
    RWN12s(RWN12s < beg_end(1) | RWN12s > beg_end(2)) = [];
    RWN12s_start = [];
    for k = 1:length(RWN12s)-23
        if all((RWN12s(k):RWN12s(k)+23) == RWN12s(k:k+23)) % check if the sequence of R, W, N12 epochs is continuous min. 12min
            RWN12s_start = [RWN12s_start, RWN12s(k)]; %#ok<AGROW>
        end
    end
    RWN12s_start2 = RWN12s_start(RWN12s_start > beg_end(1));

    % only split if there is a lightening of sleep following the onset of the NREMP
    if isempty(RWN12s_start2)
        return
    end

    % find beginnings of >12min RWN12 sequences of 'lighter' sleep
    RWN12s_start2 = RWN12s_start(1);
    for k = 1:length(RWN12s_start)-1
        if (RWN12s_start(k+1) - RWN12s_start(k)) > 1
            RWN12s_start2 = [RWN12s_start2, RWN12s_start(k+1)]; %#ok<AGROW>
        end
    end

    % find N3 episodes within period to split
    N3s = find(score == 3);
    N3s(N3s < beg_end(1) | N3s > beg_end(2)) = [];
    N3s = N3s(N3s > RWN12s_start2(1)); % only N3s after start of 12min of R/W/N1/N2

    % only split if there is N3 sleep following the onset of the NREMP
    if isempty(N3s)
        return
    end

    % find starting points of continuous N3 sequences
    N3_start = N3s(1);
    for k = 1:length(N3s)-1
        if (N3s(k+1) - N3s(k)) > 1
            N3_start = [N3_start, N3s(k+1)]; %#ok<AGROW> % if there is a discontinuity in the sequence, mark the beginning of a new 12min RWN12 sequence
        end
    end

    % select starting points of N3 following 12min of R/W/N1/2
    RWN12s_start2 = RWN12s_start2(RWN12s_start2 < max(N3_start));
    n = [];
    for k = 1:length(RWN12s_start2)
        x = N3_start - RWN12s_start2(k);
        x = min(x(x > 0));
        val = find(x == N3_start - RWN12s_start2(k));
        n = [n, val]; %#ok<AGROW>
    end

    % do not consider first N3 within NREMP
    if N3_start(1) == N3s(1)
        n(1) = [];
    end
    if isempty(n)
        return
    end
    N3_start2 = unique(N3_start(n));

    % instead of asking the user, I here search for the lightest sleep
    % epoch prior to the N3 epoch
    idx = round(median(1:length(N3_start2)));
    N3_start2 = N3_start2(idx);
    % Find last lightest sleep
    nremp_end = RWN12s_start2(find(RWN12s_start2 < N3_start2, 1, 'last'));
    nremp_end = nremp_end + find(score(nremp_end:N3_start2) == min(score(nremp_end:N3_start2)), 1, 'last');

    c = table();
    c.epoch = nremp_end;
    c.desc = {'nremp'};
    cycles = [cycles; c]; %#ok<AGROW> 
    [~, idx] = sort(cycles.epoch);
    cycles = cycles(idx, :);

end

end