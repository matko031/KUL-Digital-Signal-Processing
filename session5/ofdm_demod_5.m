function [qams, H] = ofdm_demod_5(sig, L, N, qams_length, trainblock, threshold)
    sig = reshape(sig, L+N, []);
    
    sig = sig(L+1:end, :);

    qams = fft(sig, N);
    qams = qams(1:N/2, :);
    
    H = zeros(N/2, 1);
    for i=2:N/2
        H(i) = qams(i,:) / repmat(trainblock(i-1), 1, 100);
    end

    qams = qams ./ H;

    qams = qams(abs(H) > threshold, :);
    qams = qams(:);
    qams = qams(1:qams_length);
end