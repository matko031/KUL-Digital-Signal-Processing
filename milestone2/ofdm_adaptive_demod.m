function qams = ofdm_adaptive_demod(sig, L, H, N, b, qams_length)
    sig = reshape(sig, L+N, []);
    
    sig = sig(L+1:end, :);
    
    H_inv = 1./H;

    qams = fft(sig, N);
    qams = qams(1:N/2, :);
    qams = qams .* H_inv;
    qams = qams(b > 0, :);
    qams = qams(:);
    qams = qams(1:qams_length);
end