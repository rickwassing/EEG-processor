function str = printME(ME)

str = '';

for i = 1:length(ME)
    fprintf('%s\n', ME(i).message);
    for j = 1:length(ME(i).stack)
        fprintf('    Error in %s (line %i)\n', ME(i).stack(j).name, ME(i).stack(j).line);
    end
    fprintf('\n');
    
    if nargout == 1
        str = [str; {sprintf('%s', char(ME(i).message))}];
        for j = 1:length(ME(i).stack)
            str = [str; {sprintf('    Error in %s (line %i)', ME(i).stack(j).name, ME(i).stack(j).line)}];
        end
        str = [str; {'---------------------------------------------------------'}];
    end
end

end
