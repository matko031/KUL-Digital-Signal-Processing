clearvars;
load('recvd_noise_2051.mat');
load('noise_2051.mat');

N = 1026;
M = 16;
L = 400;
Lt = 10;
fs = 16000;
[h, H] = IR2(L, fs, N, u, y, false);
threshold = 0;

train_bits = randi([0,1], sqrt(M)*(N/2-1), 1);
train_frame = qam_mod(train_bits, M);

[image_bits, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
image_qams = qam_mod(image_bits, M);
qams_length = size(image_qams,1);

Tx = ofdm_mod(image_qams, N, L, H, threshold, Lt, train_frame);

Rx = conv(Tx, h);
Rx = Rx(1:size(Tx,1));

Rx = ofdm_demod(Rx, L, N, M, qams_length, train_frame, threshold, Lt, H, image_qams);
rx_bits = qam_demod(Rx, M);

ber(image_bits, rx_bits)
