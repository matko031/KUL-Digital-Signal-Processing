clearvars;
load('recvd_noise_2051.mat');
load('noise_2051.mat');

M = 16;
N = 1026;
L = 400;
fs = 14e3;

%[h, H] = IR2(L, fs, N, u, y, false);
h = [1; zeros(399,1)];
H = ones(N/2, 1);
threshold = 0;

bit_seq = randi([0,1], sqrt(M)*(N/2-1), 1);
trainblock = qam_mod(bit_seq, M);

Tx_1 = ofdm_mod(trainblock, N, L, H, threshold);
Tx = repmat(Tx_1, 100, 1);

Rx = conv(Tx, h);
Rx = Rx(1:size(Tx, 1), :);

[Rx_qam, Hls] = ofdm_demod_5(Rx, L, N, size(trainblock,1)*100, trainblock, threshold);
Rx_qam = Rx_qam(1:size(trainblock), :);

Rx_bit_seq = qam_demod(Rx_qam, M);
BER = ber(bit_seq, Rx_bit_seq)


figure('Name','Frequency response');
f = [1: size(H, 1)];

subplot(2,1,1);
semilogy(f, abs(Hls));
title('Channel frequency response (estimation)');

subplot(2,1,2);
semilogy(f, abs(H))
title('Channel frequency response');