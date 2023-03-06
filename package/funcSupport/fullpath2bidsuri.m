function bidsuri = fullpath2bidsuri(bidspath, fullpath)

bidspath = strrep(bidspath, filesep, '/');
fullpath = strrep(fullpath, filesep, '/');

bidsuri = strrep(fullpath, [bidspath, '/'], 'bids::');

end