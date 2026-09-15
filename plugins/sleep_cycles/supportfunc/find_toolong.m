function too_long = find_toolong(score, cycles)

too_long = [];
for k = 1:size(cycles, 1)-1
    if strcmpi(cycles.desc{k}, 'remp')
        continue
    end
    this_nrem_cycle = score(cycles.epoch(k):cycles.epoch(k+1)-1);
    nwake_epochs = sum(this_nrem_cycle == 0);
    if (length(this_nrem_cycle) - nwake_epochs) >= 240
        too_long = [too_long, k]; %#ok<AGROW> 
    end
end

end