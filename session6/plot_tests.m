clearvars;
close all;
load('H_est_Felix.mat');
load('Rx_Felix.mat');

simulation = 0;

M = 16;
L = 400;
N = 1026;
Lt = 5;
Ld = 10;
fs = 16000;

BWusage = 0.7;

pulse_tlength = 1.5;
pulse_t = [0: 1/fs: pulse_tlength]';
pulse = sin(2*pi*500*pulse_t);

% H_est = estimate_channel_matko(fs, N, L, M, pulse);
H_sorted = sort(abs(H_est), 'descend');

H_est_symm = [H_est; 0; conj(flip(H_est(2:end,:)))];
h_est = ifft(H_est_symm, N);

if BWusage == 1
    threshold = 0; 
else
    threshold = H_sorted(floor(BWusage*size(H_est,1)) , 1);
end

train_bits = randi([0,1], sqrt(M)*(N/2-1), 1);
train_frame = qam_mod(train_bits, M);

% Convert BMP image to bitstream
[data_bits, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
data_qams = qam_mod(data_bits, M);
qams_length = size(data_qams,1);
Tx = ofdm_mod_matko(data_qams, N, L, H_est, threshold, Lt, Ld, train_frame);


if simulation == 1
    [simin,nbsecs,fs] = initparams_matko(Tx, fs, pulse, L);
    options = simset('SrcWorkspace','current');
    sim('recplay');
    Rx_out = simout.signals.values;
    Rx = alignIO(Rx_out, pulse);
    Rx = Rx(1:size(Tx,1));
end

[rx_qams, H, timing] = ofdm_demod(Rx, L, N, qams_length, train_frame, threshold, Lt, Ld, H_est);


Rx_bits = qam_demod(rx_qams, M);
BER = ber(data_bits , Rx_bits)

imageRx = bitstreamtoimage(Rx_bits, imageSize, bitsPerPixel);

H_symm = [H; zeros(1, size(H, 2)); conj(flip(H(2:end, :)))];
h = ifft(H_symm, N);

i=1;
n=1;
size_bitStream = size(data_bits, 1);

figure('Name','OFDM visualisation')

while i < size_bitStream
    stop = i + (Ld * (N/2-1)) * log2(M) - 1;
    
    if stop > size_bitStream
        stop = size_bitStream;
    end
    
    current_result = Rx_bits(1:stop);
    current_pad = zeros(size_bitStream-size(current_result,1),1);
    received = [current_result; current_pad];
    current_img = bitstreamtoimage(received, imageSize, bitsPerPixel);

    current_h = h(:, n);   
    current_H = H(:, n);
    current_t = timing(:, n);
    
    visualise_demod(current_img, current_h, current_H, current_t);
    
    i = stop + 1;
    n = n + 1;
    
    pause((timing(:, n)-current_t) * 200);
end

% Plot images
% figure('Name','Graphical result')
% subplot(1,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
% subplot(1,2,2); colormap(colorMap); image(imageRx); axis image; title(['Received image (OFDM)']); drawnow;


