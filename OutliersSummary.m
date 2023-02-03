% OutlierSummary.m


% Outliers

% 1.	>= 3 stages (n1, n2, n3, rem) & within stage >= 1 frequency bands (delta or beta)

% Inspect channels
% 2.	= 2 stages & within stage >= 1 frequency bands & within hot spot area (back of head, right and left side of head)
% 3.	= 1 stage & within stage >= 1 frequency bands & within hot spot area (back of head, right and left side of head), viusalize check to exclude

% right side :E210, E202, E192, E191
% 
% left side: E86, E89, E74, E83
% 
% back side : E126, E127, E133, E138, E139, E117, E118, ...
%             E115, E124, E137, E149, E159

%% prepare parameters and import data
folder_name = '/Users/tkao6355/Dropbox/05_Woolcock_DS/AnalyzeTools/BIDS_datasetTest/derivatives/EEG-output-fstlvl/sub-r0051cp/ses-1';

desc_name ='sub-r0051cp_ses-1_task-psg_run-1_src-eeg_desc-';
stages ={'n1','n2','n3','rem'};

rej_chans=[];
rej_2freqs =[];
for i_stage = 2:length(stages)
    PSD_file = load([folder_name,filesep, desc_name, char(stages(i_stage)),'_powerspect.mat']);
    rej_chans = [rej_chans, PSD_file.EEG.etc.rej_channels];
    rej_2freqs = [rej_2freqs,PSD_file.EEG.etc.rej_chan2freqs];
end


Spot_chans = {'E210', 'E202', 'E192', 'E191','E86', 'E89', 'E74', 'E83',...
              'E126', 'E127', 'E133', 'E138', 'E139', 'E117', 'E118',...
              'E115','E124','E137', 'E149', 'E159'};

savepath = [folder_name,filesep, desc_name, char(stages(1)),'-', char(stages(2)),'-',...
    char(stages(3)),'-',char(stages(4)),'_powerspect_outliers.csv'];
%% get outliers

[D1,~,X1] = unique(rej_chans(:)');
Y1 = hist(X1,unique(X1));

[D2,~,X2] = unique(rej_2freqs(:)');
Y2 = hist(X2,unique(X2));


out1 = D1(Y1==4);
out2 = intersect(D1(Y1==3),D2(Y2==3)); 
out3 = intersect(intersect(D1(Y1==2),D2(Y2==2)), Spot_chans); 
out4 = intersect(intersect(D1(Y1==1),D2(Y2==2)), Spot_chans); 


% create a table to save outlier results
sz = [100 2];
varTypes = ["string","string"];
varNames = ["Outliers","Inspect_Chans"];
OutTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

n_outliers = length([out1, out2, out3]);
OutTable(1:n_outliers,1) = array2table([out1, out2, out3]');
n_Inspect_Chans = length(out4);
OutTable(1:n_Inspect_Chans,2) = out4';


%save outliers as csv
writetable(OutTable, savepath)
exit

