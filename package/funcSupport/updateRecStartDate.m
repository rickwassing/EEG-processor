function etc = updateRecStartDate(etc, addays)

% Update the rec_startdate
etc.rec_startdate = datestr(...
    datenum(etc.rec_startdate, 'yyyy-mm-ddTHH:MM:SS') + addays, ...
    'yyyy-mm-ddTHH:MM:SS');
% remove the amp start date if it exists, this is no longer relevant
if isfield(etc, 'T0')
    etc = rmfield(etc, 'T0');
end
if isfield(etc, 'amp_startdate')
    etc = rmfield(etc, 'amp_startdate');
end

end