function [EEG, Warnings] = Proc_RejectComponents(EEG, Warnings)

if ~isfield(EEG.etc, 'rej_components')
    disp('>> BIDS: Did not remove any components, rejected components list is not specified')
    Warnings = [Warnings; {'Did not remove any components, rejected components list is not specified'}];
    Warnings = [Warnings; {'-----'}];
elseif isempty(EEG.etc.rej_components)
    disp('>> BIDS: Did not remove any components, rejected components list is empty')
    Warnings = [Warnings; {'Did not remove any components, rejected components list is empty'}];
    Warnings = [Warnings; {'-----'}];
else
    fprintf('>> BIDS: Removing %i rejected components in file ''%\s''\n', length(EEG.etc.rej_components), EEG.setname)
    EEG = pop_subcomp(EEG, EEG.etc.rej_components, 0);
    EEG.etc.subtracted_components = EEG.etc.rej_components;
    EEG.etc = rmfield(EEG.etc, 'rej_components');
end

end