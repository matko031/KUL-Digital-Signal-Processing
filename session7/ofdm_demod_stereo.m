function qams_final = ofdm_demod_stereo(sig, L, N, qams_length, trainblock, Lt, Ld, H12)
    
    sig = reshape(sig, L+N, []);
    sig = sig(L+1:end, :);

    qams = fft(sig, N);
    qams = qams ./ H12;
    
    qams = qams(2:N/2, :);
    
    P = size(qams, 2);
    if Ld == 0
        nb_full_packets = 0;
    else
        nb_full_packets = floor(P / (Lt+Ld));
    end
    nb_extra_data_frames = P - nb_full_packets*(Lt+Ld) - Lt;
    
    package = zeros(N, P);
    
    data_end = 0;
    qams_final = [];
    for i = 1:nb_full_packets
        train_start = data_end+1;
        train_end = train_start+Lt-1;
        data_start = train_end + 1;
        data_end = data_start + Ld-1;

        H = zeros(N/2, 1);
        for j=2:N/2
            H(j) = qams(j-1,train_start:train_end) / repmat(trainblock(j-1), 1, Lt);   
        end

        qams_tmp = qams(:, data_start:data_end) ./ H(2:end);
        qams_tmp = qams_tmp(:);
        qams_final = [qams_final; qams_tmp];
        
    end
    
    train_start = data_end + 1;
    train_end = train_start+Lt-1;
    data_start = train_end + 1;
    
    H = zeros(N/2, 1);
    for k = 2:N/2
            H(k) = qams(k-1,train_start:train_end) / repmat(trainblock(k-1), 1, Lt);   
    end

    qams_tmp = qams(:, data_start:end) ./ H(2:end);
    qams_tmp = qams_tmp(:);

    qams_final = [qams_final; qams_tmp];

    qams_final = qams_final(1:qams_length);

end
