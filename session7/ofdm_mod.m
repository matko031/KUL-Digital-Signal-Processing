function package = ofdm_mod(qam_seq, N, L, H, threshold, Lt, train_frame)
    H(1,1) = 0;
    
    f_size = sum(abs(H) > abs(threshold));
    qam_size = size(qam_seq, 1);
    m = mod(qam_size, f_size);
    
    padding = 0;
    if m ~= 0
        padding = f_size - m;
    end
    
    qam_seq = [qam_seq; zeros(padding, 1)];
    
    trainblock = repmat(train_frame, 1, Lt);
    trainblock_conj = conj(flip(trainblock));
    
    nb_data_frames = size(qam_seq,1) / f_size;  
    assert(mod(nb_data_frames,1)==0, 'nb_data_frames should be int, prbly smth wrong with padding');
    
    P = Lt + nb_data_frames;
    package = zeros(N, P);
    
    package(2:N/2, 1:Lt) = trainblock;
    package(N/2+2 : end, 1:Lt) = trainblock_conj;


    f1 = zeros(N/2-1, nb_data_frames);
    f1(abs(H(2:end)) > abs(threshold), :) = reshape(qam_seq, f_size, nb_data_frames);
    f2 = conj(flip(f1));
    package(:, Lt+1:end) = [zeros(1, nb_data_frames); f1; zeros(1,nb_data_frames); f2];


    sig = ifft(package, N);
    prefix = sig(end-L+1:end, :);
    package = [prefix; sig];
    package = package(:);

end
