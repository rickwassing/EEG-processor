function bidsuri = fullpath2bidsuri(bidspath, fullpath)

bidsuri = strrep(fullpath, [bidspath, '/'], 'bids::');

end