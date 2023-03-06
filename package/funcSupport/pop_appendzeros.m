function EEG = pop_appendzeros(EEG, npoints)

if EEG.trials > 1
    EEG.data = cat(2, EEG.data, zeros(EEG.nbchan, npoints, EEG.trials));
else
    EEG.data = cat(2, EEG.data, zeros(EEG.nbchan, npoints));
end
EEG.pnts = size(EEG.data, 2);
EEG.xmax = (EEG.pnts - 1) / EEG.srate + EEG.xmin;
EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
for i = 1:length(EEG.event)
    EEG.event(i).latency = EEG.event(i).latency + npoints;
end

end