clearvars;
% Exercise session 4: DMT-OFDM transmission scheme
% close all;
clear vars;

load('recvd_noise_2051.mat')
load('noise_2051.mat')
L = 400;
fs = 16000;
N = 514;
i = 6;
M = 2^i;
G = 10;
fs = 1e-3;

SNR_dB = 50;

noise = awgn(zeros(N,1), SNR_dB);
Pn = pwelch(noise, N, round(0.8*N), N, fs);
Pn = Pn(1:N/2);

[h_ir2_accoustic, H_ir2_accoustic] = IR2(L, fs, N, u, y, false);
% H_ir2_accoustic = 1 + zeros(N/2, 1);

% figure('Name','IR2 estimation');
% f_ir2 = [1: size(H_ir2_accoustic, 1)];
% semilogy(f_ir2, abs(H_ir2_accoustic))
% title('Channel frequency response');

attenuation_threshold = median(abs(H_ir2_accoustic));
attenuation_threshold = -1;

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod(bitStream, M);
[qamStream_adaptive, b] = adaptive_qam(bitStream, H_ir2_accoustic, Pn, G);

% OFDM modulation
p = 128;
ofdmStream = ofdm_mod(qamStream, N, L, H_ir2_accoustic, -1);
ofdmStream_adaptive = ofdm_adaptive_mod(qamStream_adaptive, N, L, b);

% Channel

% h = rand(1,L);
% g = [1 zeros(1, L-1)];
% ts = 10^-3;
% [signalOut, t] = lsim(H, ofdmStream);

ofdmStream_out = conv(ofdmStream, h_ir2_accoustic);
ofdmStream_adaptive_out = conv(ofdmStream_adaptive, h_ir2_accoustic);

ofdmStream_out = ofdmStream_out(1:size(ofdmStream, 1));
ofdmStream_adaptive_out = ofdmStream_adaptive_out(1:size(ofdmStream_adaptive, 1));

% Additive noise (AWGN)
rxAWGN = awgn(ofdmStream_out, SNR_dB);
rxAWGN_adaptive = awgn(ofdmStream_adaptive_out, SNR_dB);


% OFDM demodulation
rxQamStream = ofdm_demod(rxAWGN, L, H_ir2_accoustic, N, -1, size(qamStream, 1));
rxQamStream_adaptive = ofdm_adaptive_demod(rxAWGN_adaptive, L, H_ir2_accoustic, N, b, size(qamStream_adaptive, 1));

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
rxBitStream_adaptive = adaptive_qam_demod(rxQamStream_adaptive, H_ir2_accoustic, Pn, G);

% Compute BER
berTransmission = ber(bitStream, rxBitStream)
berTransmission_adaptive = ber(bitStream, rxBitStream_adaptive)

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
imageRx_onoff = bitstreamtoimage(rxBitStream_adaptive, imageSize, bitsPerPixel);

% Plot images
figure('Name','Graphical result')
subplot(1,3,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(1,3,2); colormap(colorMap); image(imageRx); axis image; title(['Received image (OFDM)']); drawnow;
subplot(1,3,3); colormap(colorMap); image(imageRx_onoff); axis image; title(['Received image (Adaptive QAM & OFDM)']); drawnow;
