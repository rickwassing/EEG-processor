function fullpath = bidsuri2fullpath(bidspath, bidsuri)

fullpath = strrep(bidsuri, 'bids::', [bidspath, '/']);

end