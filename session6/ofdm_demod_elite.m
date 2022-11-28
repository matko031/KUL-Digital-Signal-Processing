function [qams_final, channel_est] = ofdm_demod_elite(sig, L, N, qams_length, pilot_qams_tx, b)
    sig = reshape(sig, L+N, []);
    sig = sig(L+1:end, :);

    qams = fft(sig, N);
    qams = qams(2:N/2, :);

    pilot_qams_rx = qams(1:2:end, :);
    data_qams = qams(2:2:end, :);

    P = size(qams, 2);
    b_data = abs(b(3:2:end));
    qpf = sum(b_data > 0); % qams per frame

    channel_est = zeros(N/2, P);
    
    qams_final = zeros(qpf*P, 1);
    H = zeros(N/2,1);
    last = 0;
    for i = 1:P

        H_pilot = pilot_qams_rx(:, i) ./ pilot_qams_tx(:, 1);  % zonder 0
        H(2:end) = interp(H_pilot,2); % 0 terug toevoegen!
        channel_est(:, i) = H;

        qams_tmp = data_qams(:, i) ./ H(3:2:end);
        qams_tmp = qams_tmp(b_data>0);
        qams_tmp = qams_tmp(:);

        start = last + 1;
        last = start + qpf - 1;
        qams_final(start:last, 1) = qams_tmp;

    end

    qams_final = qams_final(1:qams_length);


end
