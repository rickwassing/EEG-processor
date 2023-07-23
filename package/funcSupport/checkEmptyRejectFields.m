clc
Files = dir('/Volumes/research-data/PRJ-HdEEG_Schiz/derivatives/EEG-inspect/**/sub*.set');
Files = [Files; dir('/Volumes/research-data/PRJ-CB_Insomnia/derivatives/EEG-inspect/**/sub*.set')];
Files = [Files; dir('/Volumes/research-data/PRJ-CB_Insomnia/02 Participant Data/Randomised/kdt-analysis/derivatives/EEG-inspect/**/sub*.set')];
Files = [Files; dir('/Volumes/research-data/PRJ-dasa/derivatives/EEG-inspect/**/sub*.set')];
Files = [Files; dir('/Volumes/research-data/PRJ-hdEEG_Emotion_Memory/Participant Data/Source Data/derivatives/EEG-inspect/**/sub*.set')];
Files = [Files; dir('/Volumes/research-data/PRJ-HdEEG_MCI/kdt-analysis/derivatives/EEG-inspect/**/sub*.set')];
Files = [Files; dir('/Volumes/research-data/PRJ-Local_Sleep/derivatives/EEG-inspect/**/sub*.set')];
Files = [Files; dir('/Volumes/research-data/PRJ-Local_Sleep/00PSG Database/derivatives/EEG-inspect/**/sub*.set')];

%%
for i = 1:length(Files)
    Files(i).hasEmpties = false;
    Files(i).ME = [];
end

%%
clc

for i = 1:length(Files)
    try
        fprintf('%i\n', i);
        fpath = fullfile(Files(i).folder, Files(i).name);
        EEG = LoadDataset(fpath, 'header');
        if hasEmptyRejectFields(EEG)
            fprintf('##################################################\n');
            fprintf('%s\n', fpath);
            fprintf('##################################################\n');
            Files(i).hasEmpties = true;
        end
        save('/Users/rickwassing/Local/checkEmptyField/Files.mat', 'Files');
    catch ME
        fprintf('**************************************************\n');
        disp(getReport(ME));
        Files(i).ME = ME;
        fprintf('**************************************************\n');
    end
end