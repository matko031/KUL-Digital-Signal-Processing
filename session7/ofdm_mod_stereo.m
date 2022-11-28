function [package_L, package_R] = ofdm_mod_stereo(qam_seq, N, L, Lt, Ld, train_frame, a, b)    
    f_size = N/2-1;
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
    

    nb_full_packets = floor(nb_data_frames / Ld);
    mod_data_frames = mod(nb_data_frames, Ld);
    
    P = nb_full_packets*(Lt+Ld) + Lt+ mod_data_frames;

    package = zeros(N, P);
    
    last = 0;
    data_end = 0;
    for i = 1:nb_full_packets
        
        train_start = data_end + 1;
        train_end = train_start+Lt-1;
        data_start = train_end + 1;
        data_end = data_start + Ld-1;

        package(2:N/2, train_start: train_end) = trainblock;
        package(N/2+2 : end, train_start: train_end) = trainblock_conj;

        f1 = zeros(N/2-1, Ld);
        first = last+1;
        last = first + f_size*Ld-1;

        f1 = reshape(qam_seq(first:last, 1),[],Ld) ;
        f2 = conj(flip(f1));

        package(:, data_start:data_end) = [zeros(1, Ld); f1; zeros(1,Ld); f2];
    end

    train_start = data_end + 1;
    train_end = train_start+Lt-1;
    data_start = train_end + 1;
    
    package(2:N/2, train_start: train_end) = trainblock;
    package(N/2+2:end, train_start: train_end) = trainblock_conj;


    f1 = zeros(N/2-1, mod_data_frames);
    f1 = reshape(qam_seq(last+1:end, 1),[],mod_data_frames) ;
    f2 = conj(flip(f1));
    
    package(:, data_start: end) = [zeros(1, mod_data_frames); f1; zeros(1,mod_data_frames); f2];

    package_L = a .* package;
    package_R = b .* package;
    
    sig_L = ifft(package_L, N);
    sig_R = ifft(package_R, N);
    
    prefix_L = sig_L(end-L+1:end, :);
    prefix_R = sig_R(end-L+1:end, :);
    
    package_L = [prefix_L; sig_L];
    package_R = [prefix_R; sig_R];
    
    package_L = package_L(:);
    package_R = package_R(:);

end
