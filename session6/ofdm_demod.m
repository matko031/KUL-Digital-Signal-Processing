function [qams_final, channel_est, timing] = ofdm_demod(sig, L, N, qams_length, trainblock, threshold, Lt, Ld, H_est)
    t_start = tic;

    sig = reshape(sig, L+N, []);
    
    sig = sig(L+1:end, :);

    qams = fft(sig, N);
    qams = qams(2:N/2, :);
    
    P = size(qams, 2);
    if Ld == 0
        nb_full_packets = 0;
    else
        nb_full_packets = floor(P / (Lt+Ld));
    end
    nb_extra_data_frames = P - nb_full_packets*(Lt+Ld) - Lt;
    
    channel_est = zeros(N/2, nb_full_packets + 1);
    timing = zeros(1, nb_full_packets + 1);
    
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
        
        channel_est(:, i) = H;

        qams_tmp = qams(:, data_start:data_end) ./ H(2:end);
        qams_tmp = qams_tmp(abs(H_est(2:end)) > abs(threshold), :);
        qams_tmp = qams_tmp(:);
        qams_final = [qams_final; qams_tmp];
        
        timing(:, i) = toc(t_start);
    end
    
    train_start = data_end + 1;
    train_end = train_start+Lt-1;
    data_start = train_end + 1;
    
    H = zeros(N/2, 1);
    for k = 2:N/2
            H(k) = qams(k-1,train_start:train_end) / repmat(trainblock(k-1), 1, Lt);   
    end
    channel_est(:, end) = H;

    qams_tmp = qams(:, data_start:end) ./ H(2:end);
    qams_tmp = qams_tmp(abs(H_est(2:end)) > abs(threshold), :);
    qams_tmp = qams_tmp(:);
    
    timing(:, end) = toc(t_start);

    qams_final = [qams_final; qams_tmp];

    qams_final = qams_final(1:qams_length);


end
