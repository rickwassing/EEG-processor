% saves the values in the structure 'data' to a file in JSON format.
%
% Example:
%     data.name = 'chair';
%     data.color = 'pink';
%     data.metrics.height = 0.3;
%     data.metrics.width = 1.3;
%     struct2json(data, 'out.json');
%
% Output 'out.json':
% {
% 	"name" : "chair",
% 	"color" : "pink",
% 	"metrics" : {
% 		"height" : 0.3,
% 		"width" : 1.3
% 		}
% 	}
%

function struct2json(S, jsonFileName)
if nargin == 2
    fid = fopen(jsonFileName, 'w');
else
    fid = 0;
end
sep = ',';
for i = 1:length(S)
    if i == length(S)
        sep = '';
    end
    if fid ~= 0; fprintf(fid, '{\n'); else; fprintf('{\n'); end
    writeElement(fid, S(i), fieldnames(S(i)), '');
    if fid ~= 0; fprintf(fid,'}%s\n', sep); else; fprintf('}%s\n', sep); end
end
if fid ~= 0; fclose(fid); end
end

function writeElement(fid, S, fnames, tabs)

tabs = [tabs, '\t'];

sep_j = ',';
for j = 1:length(fnames)
    if j == length(fnames)
        sep_j = '';
    end
    if isstruct(S.(fnames{j}))
        if length(S.(fnames{j})) == 1
            if fid ~= 0; fprintf(fid, [tabs, '"%s": {\n'], fnames{j}); else; fprintf([tabs, '"%s": {\n'], fnames{j}); end
            writeElement(fid, S.(fnames{j}), fieldnames(S.(fnames{j})), tabs)
            if fid ~= 0; fprintf(fid, [tabs, '}%s\n'], sep_j); else; fprintf([tabs, '}%s\n'], sep_j); end
        else
            if fid ~= 0; fprintf(fid, [tabs, '"%s": [\n'], fnames{j}); else; fprintf([tabs, '"%s": [\n'], fnames{j}); end
            tabs = [tabs, '\t']; %#ok<AGROW> 
            sep_k = ',';
            for k = 1:length(S.(fnames{j}))
                if k == length(S.(fnames{j}))
                    sep_k = '';
                end
                if fid ~= 0; fprintf(fid, [tabs, '{\n']); else; fprintf([tabs, '{\n']); end
                writeElement(fid, S.(fnames{j})(k), fieldnames(S.(fnames{j})(k)), tabs)
                if fid ~= 0; fprintf(fid, [tabs, '}%s\n'], sep_k); else; fprintf([tabs, '}%s\n'], sep_k); end
            end
            if fid ~= 0; fprintf(fid, [tabs, ']%s\n'], sep_j); else; fprintf([tabs, ']%s\n'], sep_j); end
        end
    else
        if isempty(S.(fnames{j})) && isnumeric(S.(fnames{j}))
            if fid ~= 0; fprintf(fid, [tabs, '"%s": null%s\n'], fnames{j}, sep_j); else; fprintf([tabs, '"%s": null%s\n'], fnames{j}, sep_j); end
        elseif isempty(S.(fnames{j})) && ~isnumeric(S.(fnames{j}))
            if fid ~= 0; fprintf(fid, [tabs, '"%s": ""%s\n'], fnames{j}, sep_j); else; fprintf([tabs, '"%s": ""%s\n'], fnames{j}, sep_j); end
        elseif ischar(S.(fnames{j})) || (isnumeric(S.(fnames{j})) && length(S.(fnames{j})) == 1)
            val = S.(fnames{j});
            if isnumeric(val)
                if fid ~= 0; fprintf(fid, [tabs, '"%s": %g%s\n'], fnames{j}, val, sep_j); else; fprintf([tabs, '"%s": %g%s\n'], fnames{j}, val, sep_j); end
            else
                if fid ~= 0; fprintf(fid, [tabs, '"%s": "%s"%s\n'], fnames{j}, val, sep_j); else; fprintf([tabs, '"%s": "%s"%s\n'], fnames{j}, val, sep_j); end
            end
        else
            if fid ~= 0; fprintf(fid, [tabs, '"%s": [\n'], fnames{j}); else; fprintf([tabs, '"%s": [\n'], fnames{j}); end
            sep_k = ',';
            for k = 1:length(S.(fnames{j}))
                if k == length(S.(fnames{j}))
                    sep_k = '';
                end
                if iscell(S.(fnames{j})(k))
                    val = S.(fnames{j}){k};
                else
                    val = S.(fnames{j})(k);
                end
                if isnumeric(val)
                    if fid ~= 0; fprintf(fid, [tabs, '\t%g%s\n'], val, sep_k); else; fprintf([tabs, '\t%g%s\n'], val, sep_k); end
                elseif isempty(val) && isnumeric(val)
                    if fid ~= 0; fprintf(fid, [tabs, '\tnull%s\n'], sep_k); else; fprintf([tabs, '\tnull%s\n'], sep_k); end
                elseif isempty(val) && ~isnumeric(val)
                    if fid ~= 0; fprintf(fid, [tabs, '\t""%s\n'], sep_k); else; fprintf([tabs, '\t""%s\n'], sep_k); end
                else
                    if fid ~= 0; fprintf(fid, [tabs, '\t"%s"%s\n'], val, sep_k); else; fprintf([tabs, '\t"%s"%s\n'], val, sep_k); end
                end
            end
            if fid ~= 0; fprintf(fid, [tabs, ']%s\n'], sep_j); else; fprintf([tabs, ']%s\n'], sep_j); end
        end
    end
end
end