function qams = ofdm_demod(sig, L, H, N, threshold, qams_length)
    sig = reshape(sig, L+N, []);
    
    sig = sig(L+1:end, :);
    
    qams = fft(sig, N);
    qams = qams(1:N/2, :);
    
    H_inv = 1./H;
    H_inv = [0; H_inv(2:end, :)];
    
    H(1,1) = 0;

    
    qams = qams .* H_inv;
    qams = qams(abs(H) > threshold, :);
    qams = qams(:);
    qams = qams(1:qams_length);
end

