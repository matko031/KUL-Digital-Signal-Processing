clearvars;
% Exercise session 4: DMT-OFDM transmission scheme

load('recvd_noise_2051.mat')
load('noise_2051.mat')
L = 400;
fs = 16000;
N = 514;
i = 6;
M = 2^i;

attenuation_threshold = 5e-1;

[h_ir2_accoustic, H_ir2_accoustic] = IR2(L, fs, N, u, y, false);

% figure('Name','IR2 estimation');
% t_ir2 = [1: size(h_ir2_accoustic, 1)]*fs;
% x_IR2 = [1: size(h_ir2_accoustic, 1)];
% 
% subplot(2, 1, 1);
% plot(t_ir2, h_ir2_accoustic)
% title('Channel time response');


% subplot(2, 1, 2);
f = [1: size(H_ir2_accoustic, 1)]'*fs/N;
moreThanThreshold = H_ir2_accoustic > attenuation_threshold;
H_ir2_strong_f = f(moreThanThreshold);
H_ir2_strong = H_ir2_accoustic(moreThanThreshold);

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod(bitStream, M);


% OFDM modulation
p = 128;
ofdmStream = ofdm_mod(qamStream, N, L, H_ir2_accoustic, 0.4);

% Channel
SNR_dB = 70;
% h = rand(1,L);
% g = [1 zeros(1, L-1)];
% ts = 10^-3;
% [signalOut, t] = lsim(H, ofdmStream);



ofdmStream_out = conv(ofdmStream, h_ir2_accoustic);
ofdmStream_out = ofdmStream_out(1:size(ofdmStream, 1));

% Additive noise (AWGN)
rxAWGN = awgn(ofdmStream_out, SNR_dB);


% OFDM demodulation
rxQamStream = ofdm_demod(rxAWGN, L, H_ir2_accoustic, N, 0.4, size(qamStream, 1));

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
berTransmission = ber(bitStream, rxBitStream)

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure('Name','Graphical result')
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
