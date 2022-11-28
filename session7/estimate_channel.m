function [H_L, H_R, noise] = estimate_channel(fs, N, L, M, pulse)
    % generate train_frame and pass it to function, qam_seq is [] since Ld=0
    t_total = 1.5;
    
    train_bits = randi([0,1], sqrt(M)*(N/2-1), 1); % size = sqrt(M) * N/2 - 1 
    train_frame = qam_mod(train_bits, M); % size = N/2 -1
    trainblock = repmat(train_frame, round(t_total/ (N/fs)), 1);
    
    Tx_train = ofdm_mod_simple(trainblock, N, L);
    
    Tx_L = [Tx_train; zeros(size(Tx_train, 1), 1)];
    Tx_R = [zeros(size(Tx_train, 1), 1); Tx_train];

    [simin,nbsecs,fs] = initparams_stereo(Tx_L, Tx_R, fs, pulse, L);
    options = simset('SrcWorkspace','current');
    sim('recplay', [], options);
    
    Rx_train_out = simout.signals.values;
    Rx_train = alignIO(Rx_train_out, pulse);
    
    Rx_L = Rx_train(1:size(Tx_train,1));
    Rx_R = Rx_train(size(Tx_train,1)+1 : 2*size(Tx_train,1));

    noise = Rx_train_out(round(fs*0.5):round(fs*1.5));
    
    H_L = ofdm_demod_estimate(Rx_L, L, N, train_frame);
    H_R = ofdm_demod_estimate(Rx_R, L, N, train_frame);

end

