function package = ofdm_mod_simple(qam_seq, N, L)    
    f_size = N/2 -1;
    qam_size = size(qam_seq, 1);
    m = mod(qam_size, f_size);
    
    padding = 0;
    if m ~= 0
        padding = f_size - m;
    end
    
    qam_seq = [qam_seq; zeros(padding, 1)];
   
    P = size(qam_seq,1) / f_size;  
    assert(mod(P,1)==0, 'P should be int, prbly smth wrong with padding')
    package = zeros(N/2, P);
    
    last = 0;
    for i = 1:P
        first = last+1;
        last = first + f_size - 1;
        f1= qam_seq(first:last, 1);
        package(2:N/2, i) = f1;
    end

    flipped_package = flip(conj(package(2:end,:)));
    package = [package; zeros(1,P); flipped_package];

    sig = ifft(package, N);
    prefix = sig(end-L+1:end, :);
    package = [prefix; sig];
    package = package(:);
end