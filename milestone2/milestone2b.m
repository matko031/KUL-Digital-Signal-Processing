close all;
clearvars;
% Exercise session 4: DMT-OFDM transmission scheme

load('recvd_noise_2051.mat')
load('noise_2051.mat')
L = 400;
fs = 16000;
N = 514;
i = 6;
M = 2^i;

[h_ir2_accoustic, H_ir2_accoustic] = IR2(L, fs, N, u, y, false);
%H_ir2_accoustic = 1 + zeros(N/2, 1);

figure('Name','IR2 estimation');
f_ir2 = [1: size(H_ir2_accoustic, 1)];
semilogy(f_ir2, abs(H_ir2_accoustic))
title('Channel frequency response');

attenuation_threshold = median(abs(H_ir2_accoustic));

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
p = 128;
threshold = 0;
ofdmStream = ofdm_mod(qamStream, N, L, H_ir2_accoustic, threshold);
ofdmStream_onoff = ofdm_mod(qamStream, N, L, H_ir2_accoustic, attenuation_threshold);

% Channel
SNR_dB = 10^100;
% h = rand(1,L);
% g = [1 zeros(1, L-1)];
% ts = 10^-3;
% [signalOut, t] = lsim(H, ofdmStream);

ofdmStream_out = conv(ofdmStream, h_ir2_accoustic);
ofdmStream_onoff_out = conv(ofdmStream_onoff, h_ir2_accoustic);

ofdmStream_out = ofdmStream_out(1:size(ofdmStream, 1));
ofdmStream_onoff_out = ofdmStream_onoff_out(1:size(ofdmStream_onoff, 1));

% Additive noise (AWGN)
rxAWGN = awgn(ofdmStream_out, SNR_dB);
rxAWGN_onoff = awgn(ofdmStream_onoff_out, SNR_dB);


% OFDM demodulation
rxQamStream = ofdm_demod(rxAWGN, L, H_ir2_accoustic, N, threshold, size(qamStream, 1));
rxQamStream_onoff = ofdm_demod(rxAWGN_onoff, L, H_ir2_accoustic, N, attenuation_threshold, size(qamStream, 1));


% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
rxBitStream_onoff = qam_demod(rxQamStream_onoff, M);

% Compute BER
berTransmission = ber(bitStream, rxBitStream)
berTransmission_onoff = ber(bitStream, rxBitStream_onoff)

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
imageRx_onoff = bitstreamtoimage(rxBitStream_onoff, imageSize, bitsPerPixel);

% Plot images
figure('Name','Graphical result')
subplot(1,3,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(1,3,2); colormap(colorMap); image(imageRx); axis image; title(['Received image (OFDM)']); drawnow;
subplot(1,3,3); colormap(colorMap); image(imageRx_onoff); axis image; title(['Received image (OFDM & On-Off)']); drawnow;
