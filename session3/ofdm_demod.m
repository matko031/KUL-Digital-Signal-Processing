function qams = ofdm_demod(sig, L, H, N, threshold, qams_length)
    sig = reshape(sig, L+N, []);
    
    sig = sig(L+1:end, :);
    
    H_inv = 1./H;

    qams = fft(sig, N);
    qams = qams(1:N/2, :);
    qams = qams .* H_inv;
    qams = qams(H > threshold, :);
    qams = qams(:);
    qams = qams(1:qams_length);

end

