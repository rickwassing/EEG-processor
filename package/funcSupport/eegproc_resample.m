function tmpeeglab = eegproc_resample(data, p, q, usesigproc, fc, df)

if length(data) < 2
    tmpeeglab = data;
    return;
end

if usesigproc
    % padding to avoid artifacts at the beginning and at the end
    % Andreas Widmann May 5, 2011

    %The pop_resample command introduces substantial artifacts at beginning and end
    %of data when raw data show DC offset (e.g. as in DC recorded continuous files)
    %when MATLAB Signal Processing Toolbox is present (and MATLAB resample.m command
    %is used).
    %Even if this artifact is short, it is a filtered DC offset and will be carried
    %into data, e.g. by later highpass filtering to a substantial amount (easily up
    %to several seconds).
    %The problem can be solved by padding the data at beginning and end by a DC
    %constant before resampling.

    %         N = 10; % Resample default
    %         nPad = ceil((max(p, q) * N) / q) * q; % # datapoints to pad, round to integer multiple of q for unpadding
    %         tmpeeglab = resample([data(ones(1, nPad), :); data; data(end * ones(1, nPad), :)], pnts, new_pnts);

    % Conservative custom anti-aliasing FIR filter, see bug 1757
    nyq = 1 / max([p q]);
    fc = fc * nyq; % Anti-aliasing filter cutoff frequency
    df = df * nyq; % Anti-aliasing filter transition band width
    m = pop_firwsord('kaiser', 2, df, 0.002); % Anti-aliasing filter kernel
    b = firws(m, fc, windows('kaiser', m + 1, 5)); % Anti-aliasing filter kernel
    b = p * b; % Normalize filter kernel to inserted zeros
    %         figure; freqz(b, 1, 2^14, q * 1000) % Debugging only! Sampling rate hardcoded as it is unknown in this context. Manually adjust for debugging!

    % Padding, see bug 1017
    nPad = ceil((m / 2) / q) * q; % Datapoints to pad, round to integer multiple of q for unpadding
    startPad = repmat(data(1, :), [nPad 1]);
    endPad = repmat(data(end, :), [nPad 1]);

    % Resampling
    tmpeeglab = resample([startPad; data; endPad], p, q, b);

    % Remove padding
    nPad = nPad * p / q; % # datapoints to unpad
    tmpeeglab = tmpeeglab(nPad + 1:end - nPad, :); % Remove padded data

else % No Signal Processing toolbox

    % anti-alias filter
    % -----------------
    if p < q, nyq = p / q; else nyq = q / p; end
    fc = fc * nyq; % Anti-aliasing filter cutoff frequency
    df = df * nyq; % Anti-aliasing filter transition band width
    m = pop_firwsord('kaiser', 2, df, 0.002); % Anti-aliasing filter kernel
    b = firws(m, fc, windows('kaiser', m + 1, 5)); % Anti-aliasing filter kernel
    if p < q % Downsampling, anti-aliasing filter
        data = firfiltdcpadded(b, data, 0);
    end

    % spline interpolation
    % --------------------
    % New time axis scaling, May 06, 2015, AW
    X = 0:length(data) - 1;
    newpnts  = ceil(length(data) * p / q);
    XX = (0:newpnts - 1) / (p / q);

    cs = spline( X, data);
    tmpeeglab = ppval(cs, XX)';

    if p > q % Upsampling, anti-imaging filter
        tmpeeglab = firfiltdcpadded(b, tmpeeglab, 0);
    end

end