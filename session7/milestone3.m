clearvars;
close all;
% load('H_est_Felix.mat');
% load('Rx_Felix.mat');

simulation = 1;

M = 16;
L = 400;
N = 1026;
Lt = 5;
Ld = 10;
fs = 16000;



pulse_tlength = 1.5;
pulse_t = [0: 1/fs: pulse_tlength]';
%'
pulse = sin(2*pi*500*pulse_t);

if simulation == 1
	[H_est, noise] = estimate_channel(fs, N, L, M, pulse);
end
H_sorted = sort(abs(H_est), 'descend');

G = 10^10;
Pn = pwelch(noise, N, round(0.8*N), N, fs);
Pn = Pn(1:N/2);

for BWusage = 1:-0.5:0


    if BWusage == 1
        threshold = 0;
    elseif BWusage ~= 0
        threshold = H_sorted(floor(BWusage*size(H_est,1)) , 1);
        nb_used_freq = size(H_est > threshold, 1);
    end

    train_bits = randi([0,1], sqrt(M)*(N/2-1), 1);
    train_frame = qam_mod(train_bits, M);

    [data_bits, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

    if BWusage == 0
        [data_qams, b] = qam_mod_adaptive(data_bits, H_est, Pn, G);
        Tx = ofdm_mod_adaptive(data_qams, N, L, b, Lt, Ld, train_frame);
    else
        data_qams = qam_mod(data_bits, M);
        Tx = ofdm_mod(data_qams, N, L, H_est, threshold, Lt, Ld, train_frame);
    end

    qams_length = size(data_qams,1);

    [simin,nbsecs,fs] = initparams(Tx, fs, pulse, L);
    options = simset('SrcWorkspace','current');

    start_time = tic;
    sim('recplay');
    elapsed_time = toc(start_time)

    Rx_out = simout.signals.values;
    Rx = alignIO(Rx_out, pulse);
    Rx_ofdm = Rx(1:size(Tx,1));
    %%
    if BWusage == 0
        [rx_qams, H] = ofdm_demod_adaptive(Rx_ofdm, L, N, qams_length, train_frame, Lt, Ld, b);
        Rx_bits = qam_demod_adaptive(rx_qams, b, size(data_bits,1));
    else
        [Rx_qams, H] = ofdm_demod(Rx_ofdm, L, N, qams_length, train_frame, threshold, Lt, Ld, H_est);
        Rx_bits = qam_demod(Rx_qams, M);
    end

    BER = ber(data_bits , Rx_bits)

    H_symm = [H; zeros(1, size(H, 2)); conj(flip(H(2:end, :)))];
    h = ifft(H_symm, N);
%%
    i=1;
    n=1;
    last_t=0;
    last_stop=0;
    size_bitStream = size(data_bits, 1);

    BWusage_procent = num2str(BWusage*100);
    if BWusage ==0
        figure_title = 'OFDM visualisation (adaptive bitloading)';
    else
        figure_title = ['OFDM visualisation (' BWusage_procent '% BW usage)'];
    end
    figure('Name', figure_title);

    while i < size_bitStream
        if BWusage ~= 0
            stop = i + (Ld * (N/2-1)) * log2(M) - 1;
        else
            stop = size_bitStream;
        end

        if stop > size_bitStream
            stop = size_bitStream;
        end

        current_result = Rx_bits(1:stop);
        current_pad = zeros(size_bitStream-size(current_result,1),1);
        received = [current_result; current_pad];
        current_img = bitstreamtoimage(received, imageSize, bitsPerPixel);

        current_h = h(:, n);
        current_H = H(:, n);

        i = stop + 1;
        n = n + 1;

        if BWusage ~= 0
            current_H(abs(H_est)<threshold) = 0;
            current_t = last_t + (Lt+Ld)*N / (fs*BWusage);
            visualise_demod(current_img, current_h, current_H, current_t, fs, N);
            pause(current_t-last_t);
        else
            visualise_demod(current_img, current_h, current_H, 0, fs, N);
            current_t = 0;
            pause(1);
        end

        last_t = current_t;
    end

    pause(3)

end
