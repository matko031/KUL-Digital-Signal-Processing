clearvars;
load('recvd_noise_2051.mat');
load('noise_2051.mat');

M = 16;
L = 400;
N = 514;
fs = 14000;
G = 10;

SNR_dB = 10;
noise = awgn(zeros(N,1), SNR_dB);
Pn = pwelch(noise, N, round(0.8*N), N, fs);
Pn = Pn(1:N/2);

Lt = 5;
Ld = 10;

[h, H] = IR2(L, fs, N, u, y, false);
% h = [1; zeros(399,1)];
% H = ones(N/2, 1);
H(1,1) = 0;
BWusage = 0.9;
H_sorted = sort(abs(H), 'descend');

if BWusage == 1
    threshold = 0; 
else
    threshold = H_sorted(floor(BWusage*size(H,1)) , 1);
end

train_bits = randi([0,1], sqrt(M)*(N/2-1), 1);
train_frame = qam_mod(train_bits, M);

tx_bits = randi([0 1], 10000, 1);
[tx_qams, b] = qam_mod_adaptive(tx_bits, H, Pn, G);
b = b(2:end);
tx_qams_length = size(tx_qams, 1);

Tx = ofdm_mod_adaptive(tx_qams, N, L, b, threshold, Lt, Ld, train_frame);

Rx = conv(Tx, h);
Rx = Rx(1:size(Tx,1));
Rx = ofdm_demod_adaptive(Rx, L, N, tx_qams_length, train_frame, threshold, Lt, Ld, b);

rx_bits = qam_demod_adaptive(Rx, b, size(tx_bits,1));

ber(tx_bits, rx_bits)
