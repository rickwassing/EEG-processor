function EEG = pop_prependzeros(EEG, npoints)

if EEG.trials > 1
    EEG.data = cat(2, zeros(EEG.nbchan, npoints, EEG.trials), EEG.data);
else
    EEG.data = cat(2, zeros(EEG.nbchan, npoints), EEG.data);
end
EEG.pnts = size(EEG.data, 2);
EEG.xmax = (EEG.pnts - 1) / EEG.srate + EEG.xmin;
EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
for i = 1:length(EEG.event)
    EEG.event(i).latency = EEG.event(i).latency + npoints;
end

end