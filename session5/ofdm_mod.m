function package = ofdm_mod(qam_seq, N, L, H, threshold)
    H(1,1) = 0;
    
    f_size = sum(abs(H) > threshold);
    qam_size = size(qam_seq, 1);
    m = mod(qam_size, f_size);
    
    padding = 0;
    if m ~= 0
        padding = f_size - m;
    end
    
    qam_seq = [qam_seq; zeros(padding, 1)];
    
    P = size(qam_seq,1) / f_size;
        
    package = zeros(N, P);
    
    last = 0;
    for i = 1:P
        f1 = zeros(N/2, 1);
        first = last+1;
        last = first + f_size-1;
        f1(abs(H) > threshold) = qam_seq(first:last, 1);
        f2 = conj(flip(f1));
        package(:, i) = [f1; f2];
    end
    
    sig = ifft(package, N);
    prefix = sig(end-L+1:end, :);
    package = [prefix; sig];
    package = package(:);

end