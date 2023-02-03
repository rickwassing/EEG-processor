function html = generateHTML(S)

% init
html = '';
% Get all the key names from this element
keys = fieldnames(S);
% Start the HTML element
html = sprintf('%s<%s', html, S.el);
% For each key...
for k = 1:length(keys)
    % ... first check it's not a child or content, that comes later
    if ismember(keys{k}, {'el', 'c', 'content'})
        continue
    end
    % ... if this key has a value add the key-value pair
    if ~isempty(S.(keys{k}))
        html = sprintf('%s %s="%s"', html, strrep(keys{k}, '_', '-'), S.(keys{k}));
    elseif S.(keys{k})
        % ... otherwise if its a boolean, only add the key
        html = sprintf('%s %s', html, strrep(keys{k}, '_', '-'));
    end
end
% close the opening tag
html = sprintf('%s>\n', html);
% now insert child if there are any
if ismember('c', keys)
    for c = 1:length(S.c)
        html = sprintf('%s%s\n', html, generateHTML(S.c(c)));
    end
end
if ismember('content', keys)
    html = sprintf('%s%s\n', html, S.content);
end
% insert closing tag
html = sprintf('%s</%s>\n', html, S.el);

end