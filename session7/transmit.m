clearvars;
M = 16;
L = 400;
N = 1026;
Lt = 0;
Ld = 10;
fs = 16000;
G = 10^10;


pulse_tlength = 1.5;
pulse_t = [0: 1/fs: pulse_tlength]';
pulse = sin(2*pi*500*pulse_t);

[H_est, noise] = estimate_channel(fs, N, L, M, pulse);

Pn = pwelch(noise, N, round(0.8*N), N, fs);
Pn = Pn(1:N/2);

nbPilot = floor(N/4);
pilot_bits = randi([0,1], sqrt(M)*nbPilot, 1);
pilot_qams = qam_mod(pilot_bits, M);


[data_bits, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
[data_qams, b] = qam_mod_adaptive(data_bits, H_est, Pn, G);
qams_length = size(data_qams,1);
Tx = ofdm_mod_elite(data_qams, N, L, b, pilot_qams);

[simin,nbsecs,fs] = initparams_matko(Tx, fs, pulse, L);
options = simset('SrcWorkspace','current');
sim('recplay');
Rx_out = simout.signals.values;
Rx = alignIO(Rx_out, pulse);
Rx = Rx(1:size(Tx,1));

% [rx_qams, H] = ofdm_demod(Rx, L, N, qams_length, train_frame, threshold, Lt, Ld, H_est);
%%
[rx_qams, H] = ofdm_demod_elite(Rx, L, N, qams_length, pilot_qams, b);


% rx_bits = qam_demod(rx_qams, M);
%%
rx_bits = qam_demod_adaptive(rx_qams, b, size(data_bits,1));


ber(data_bits ,rx_bits)

imageRx = bitstreamtoimage(rx_bits, imageSize, bitsPerPixel);


% Plot images
figure('Name','Graphical result')
subplot(1,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(1,2,2); colormap(colorMap); image(imageRx); axis image; title(['Received image (OFDM)']); drawnow;


% H_symm = [H; zeros(1, size(H, 2)); conj(flip(H(2:end)))];
% h = ifft(H_symm, N);
% 
% i=1;
% n=1;
% size_bitStream = size(bitStream, 1);
% 
% while i < size_bitStream
%     stop = i + (Lt * (N/2-1)) - 1;
%     
%     current_result = bit_Rx(1:stop);
%     current_pad = zeros(size_bitStream-size(current_result,1),1);
%     received = [current_result; current_pad];
%     current_img = bitstreamtoimage(received, imageSize, bitsPerPixel);
% 
%     current_h = h(:, n);   
%     current_H = H(:, n);
%     current_t = timing(:, n);
%     
%     visualise_demod(current_img, current_h, current_H, current_t);
%     
%     i = stop + 1;
%     n = n + 1;
%     
%     pause(timing(:, n)-current_t);
% end

% Plot images
% figure('Name','Graphical result')
% subplot(1,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
% subplot(1,2,2); colormap(colorMap); image(imageRx); axis image; title(['Received image (OFDM)']); drawnow;


