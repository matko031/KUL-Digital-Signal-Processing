clearvars;
close all;

load('recvd_noise_2051.mat');
load('noise_2051.mat');

N = 1026;
M = 16;
L = 400;
Lt = 5;
Ld = 10;
fs = 16000;

SNR = 50;

h_length = 200;

[h, H] = IR2(L, fs, N, u, y, false);
h_L = h*(2i+1);
h_R = h*(-i+3);

[a, b, H1, H2, H12] = fixed_transmitter_side_beamformer(h_L, h_R, N);

f_axis = [0:N/2-1]'*fs/N';

figure();
hold on;
semilogy(f_axis, abs(H1(1:N/2)))
semilogy(f_axis, abs(H2(1:N/2)))
semilogy(f_axis, abs(H12(1:N/2)))
legend("H_1","H_2","H_1_2");


%%
train_bits = randi([0,1], sqrt(M)*(N/2-1), 1);
train_frame = qam_mod(train_bits, M);

[image_bits, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
image_qams = qam_mod(image_bits, M);
qams_length = size(image_qams,1);

threshold = 0;

a = [1; 0; a];
b = [0; 1; b];

for k = 1:3

    [ofdm_L, ofdm_R] = ofdm_mod_stereo(image_qams, N, L, Lt, Ld, train_frame, a(k), b(k));

    ofdm_L_Rx = conv(ofdm_L, h_L);
    ofdm_R_Rx = conv(ofdm_R, h_R);

    ofdm_L_Rx = ofdm_L_Rx(1:size(ofdm_L, 1));
    ofdm_R_Rx = ofdm_R_Rx(1:size(ofdm_R, 1));

    ofdm_L_Rx = awgn(ofdm_L_Rx, SNR);
    ofdm_R_Rx = awgn(ofdm_R_Rx, SNR);

    ofdm_Rx = ofdm_L_Rx + ofdm_R_Rx;

    qams_Rx = ofdm_demod_stereo(ofdm_Rx, L, N, qams_length, train_frame, Lt, Ld, H12);
    rx_bits = qam_demod(qams_Rx, M);

    ber(image_bits, rx_bits)
    
    imageRx = bitstreamtoimage(rx_bits, imageSize, bitsPerPixel);
    
    figure()
    colormap(colorMap); image(imageRx); axis image; title('Original image'); drawnow;
    
end









