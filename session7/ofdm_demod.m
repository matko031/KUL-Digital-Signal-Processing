function [qams_final, H] = ofdm_demod(sig, L, N, M, qams_length, train_frame, threshold, Lt, H_bitloading, orig_qams)
    H_bitloading(1,1) = 0;
    sig = reshape(sig, L+N, []);
    
    sig = sig(L+1:end, :);

    qams = fft(sig, N);
    qams = qams(2:N/2, :);
    train_qams = qams(:,1:Lt);
    data_qams = qams(:, Lt+1:end);
    
    P = size(data_qams, 2);
   
    nb_data_frames = P;
        
    H = zeros(N/2, 1);
    for j=2:N/2
        H(j) = train_qams(j-1,1:Lt) / repmat(train_frame(j-1), 1, Lt); 
    end

    W = 1 ./ conj(H);
    
    mu = 0.05;
    alpha = 10^-5;
    e = zeros(N/2-1, nb_data_frames);    

    qams_final = [];

    f = 1:N/2;
    for i = 1:nb_data_frames 
            disp(i + " out of " + nb_data_frames + " frames demodulated");
            for k = f(abs(H_bitloading(2:end))>threshold)
                u = data_qams(k, i);
                d = estimate_qam(M, u*conj(W(k+1)));
                e(k,i) = abs(d - conj(W(k+1))*u);
                W(k+1) = W(k+1) + (mu / (alpha + conj(u)*u)) * u * conj(e(k,i));
                % k=1 corresponds to the second frequency bin, W just like H
                % goes from DC to N/2 frequency bin, so we have to index it
                % with k+1
            end

        qams_tmp = data_qams(:, i) .* conj(W(2:end)); 
        qams_tmp = qams_tmp(abs(H_bitloading(2:end)) > abs(threshold), :); 
        qams_final = [qams_final; qams_tmp];  
    end
    qams_final = qams_final(1:qams_length);


end
