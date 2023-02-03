function List = selectFieldFromStructList(S, Fields)

try
    % Indicates which struct contains all requested fields
    idx = true(size(S));
    % Start building the select statement
    selector = 's';
    % For each requested field...
    for i = 1:length(Fields)
        % ... check which element in S has the requested field
        idx = idx .* eval(sprintf('cellfun(@(s) isfield(%s, Fields{i}), S)', selector));
        % ... append the fieldname with a '.' in between
        selector = [selector, '.', Fields{i}]; %#ok<AGROW>
    end
    List = eval(sprintf('cellfun(@(s) %s, S(idx == 1), ''UniformOutput'', false)', selector));
catch
    List = {};
end

end
