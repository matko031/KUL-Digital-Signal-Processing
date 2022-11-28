function package = ofdm_mod_elite(qam_seq, N, L, b, pilot_qams)
    
    b_data = abs(b(3:2:end));
    f_size = sum( b_data > 0);
    qam_size = size(qam_seq, 1);
    m = mod(qam_size, f_size);
    nbDataBins = size(b_data,1);
    padding = 0;
    if m ~= 0
        padding = f_size - m;
    end
    qam_seq = [qam_seq; zeros(padding, 1)];
    
    P = size(qam_seq,1) / f_size;  
    assert(mod(P,1)==0, 'P should be int, prbly smth wrong with padding');
    
    package = zeros(N/2, P);

    last = 0;
    for i = 1:P
    
        package(2:2:N/2, i) = pilot_qams;
%         package(N/2+2:2:end, i) = conj(flip(pilot_qams));

        f1 = zeros(nbDataBins,1);
        first = last+1;
        last = first + f_size - 1;

        f1(b_data > 0, 1) = qam_seq(first:last, 1);
%         f2 = conj(flip(f1));
        package(1:2: N/2, i) = [0; f1;];
       
    end

    flipped_package = flip(conj(package(2:end,:)));
    package = [package; zeros(1,P); flipped_package];

    sig = ifft(package, N);
    prefix = sig(end-L+1:end, :);
    package = [prefix; sig];
    package = package(:);

end
