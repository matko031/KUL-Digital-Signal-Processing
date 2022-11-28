clearvars;
load('recvd_noise_2051.mat');
load('noise_2051.mat');

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

M = 16;
N = 1026;
L = 400;
Ld = 10;
Lt = 5;
fs = 14e3;

pulse_tlength = 1.5;
pulse_t = [0: 1/fs: pulse_tlength]';
pulse = sin(2*pi*500*pulse_t);

H = estimate_channel_matko(fs, N, L, M, pulse);
h = ifft(H, N);

threshold = 0;

% QAM modulation
qam_Tx = qam_mod(bitStream, M);
qam_Tx_length = size(qam_Tx, 1);

bit_seq = randi([0,1], sqrt(M)*(N/2-1), 1);
trainblock = qam_mod(bit_seq, M);

Tx = ofdm_mod(qam_Tx, N, L, H, threshold, Lt, Ld, trainblock);


% Rx = simulate_channel(Tx, Lt, Ld, N, L);
Rx = conv(h, Tx);
Rx = Rx(1:size(Tx,1));

[qam_Rx, channel_est, timing] = ofdm_demod(Rx, L, N, qam_Tx_length, trainblock, threshold, Lt, Ld);
bit_Rx = qam_demod(qam_Rx, M);

BER = ber(bitStream, bit_Rx)

H_symm = [H; 0; conj(flip(H(2:end)))];
h = ifft(H_symm, N);

i=1;
n=1;
size_bitStream = size(bitStream, 1);

while i < size_bitStream
    stop = i + (Lt * (N/2-1)) - 1;
    
    current_result = bit_Rx(1:stop);
    current_pad = zeros(size_bitStream-size(current_result,1),1);
    received = [current_result; current_pad];

    current_h = h(:, n);   
    current_H = H(:, n);
    current_t = timing(:, n);
    
    visualise_demod(received, current_h, current_H, current_t);
    
    i = stop + 1;
    n = n + 1;
    
    pause(timing(:, n)-current_t);
end

