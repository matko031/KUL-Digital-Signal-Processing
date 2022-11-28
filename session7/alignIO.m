function [out_aligned] = alignIO(out, pulse, L)
    [C, lag] = xcorr(out, pulse); % C=corr coefficient, lag=time_delta of pulse
    [~, I] = max(C); % M=max value, I=index of max value
    t = lag(I);
    pulse_len = size(pulse,1);
    out_aligned = out(t+pulse_len+400-20:end);
end