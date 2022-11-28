function H = ofdm_demod_estimate(sig, L, N, train_frame)
    sig = reshape(sig, L+N, []);
    sig = sig(L+1:end, :);
    P = size(sig,2);

    qams = fft(sig, N);
    qams = qams(2:N/2, :);
   
    H = zeros(N/2,1);
    for i = 1:N/2-1
        H(i+1) = qams(i, :) / repmat(train_frame(i,1), 1, P);
    end

end
