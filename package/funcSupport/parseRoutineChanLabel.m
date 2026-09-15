function [label, ref, iseeg] = parseRoutineChanLabel(chanlist)

label = cell(length(chanlist), 1);
ref = cell(length(chanlist), 1);
iseeg = false(length(chanlist), 1);
for i = 1:length(chanlist)
    % Check if it matches the regexp for an EEG channel
    if startsWith(chanlist{i},'CPA')
        label{i}=chanlist{i};
        continue
    end
    iseeg(i) = ~isempty(regexp(lower(chanlist{i}), '^[fcpotma](\d+|[pz])', 'once'));
    % if it is not EEG, then simply return the label
    if ~iseeg(i)
        label{i} = chanlist{i};
        continue
    end
    % We assume here that the first two or three characters denotes the EEG chan label
    if strcmpi(chanlist{i}(2), 'p')
        label{i} = chanlist{i}(1:3);
        % The rest is the reference
        tmp = chanlist{i}(4:end);
    else
        label{i} = chanlist{i}(1:2);
        % The rest is the reference
        tmp = chanlist{i}(3:end);
    end
    % Check if M1 or A1 is in the reference string
    ism1 = ~isempty(regexp(lower(tmp), '[am][1]', 'once'));
    % and check if M2 or A2 is in the reference string
    ism2 = ~isempty(regexp(lower(tmp), '[am][2]', 'once'));
    % Return the reference channels
    if ism1 && ism2
        ref{i} = {'M1', 'M2'};
    elseif ism1
        ref{i} = 'M1';
    elseif ism2
        ref{i} = 'M2';
    else
        ref{i} = 'common';
    end


end

end