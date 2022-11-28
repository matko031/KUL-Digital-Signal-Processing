clearvars;
close all;

N = 1026;
M = 16;
L = 400;
Lt = 5;
Ld = 10;
fs = 16000;

pulse_tlength = 1.5;
pulse_t = [0: 1/fs: pulse_tlength]';
pulse = sin(2*pi*500*pulse_t);

[H_L_est, H_R_est, noise] = estimate_channel(fs, N, L, M, pulse);
%%
h_L_est = ifft(H_L_est, N);
h_R_est = ifft(H_R_est, N);

t_axis = [1: size(h_L_est, 1)]';
f_axis = fs*[1: size(H_L_est, 1)]/N';

dB_L_est = mag2db(abs(H_L_est));
dB_R_est = mag2db(abs(H_R_est));

figure('Name', 'Channel estimation');
subplot(2,2,1); plot(t_axis, h_L_est); title('Estimated left channel impulse response'); ylim([-1 1]);
subplot(2,2,2); plot(f_axis, dB_L_est); title('Estimated left frequency response (amplitude)'); ylabel('dB'); ylim([-50, 25]);
subplot(2,2,3); plot(t_axis, h_R_est); title('Estimated right channel impulse response'); ylim([-1 1]);
subplot(2,2,4); plot(f_axis, dB_R_est); title('Estimated right frequency response (amplitude)'); ylabel('dB'); ylim([-50, 25]);

[a, b, H1, H2, H12] = fixed_transmitter_side_beamformer(h_L_est, h_R_est, N);

figure('Name', 'Channel comparison');
hold on
plot(f_axis, mag2db(abs(H1(1:N/2)))); ylim([-50, 25]);
plot(f_axis, mag2db(abs(H2(1:N/2)))); ylim([-50, 25]);
plot(f_axis, mag2db(abs(H12(1:N/2)))); ylim([-50, 25]);
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

    ofdm_L_Rx = conv(ofdm_L, h_L_est);
    ofdm_R_Rx = conv(ofdm_R, h_R_est);

    ofdm_L_Rx = ofdm_L_Rx(1:size(ofdm_L, 1));
    ofdm_R_Rx = ofdm_R_Rx(1:size(ofdm_R, 1));

    ofdm_Rx = ofdm_L_Rx + ofdm_R_Rx;

    qams_Rx = ofdm_demod_stereo(ofdm_Rx, L, N, qams_length, train_frame, Lt, Ld, H12);
    rx_bits = qam_demod(qams_Rx, M);

    ber(image_bits, rx_bits)
    
    imageRx = bitstreamtoimage(rx_bits, imageSize, bitsPerPixel);
    
    figure()
    colormap(colorMap); image(imageRx); axis image; title('Original image'); drawnow;
    
end









