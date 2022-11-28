%% Exercise 1.2: Time-frequency analysis of recorded signals

clearvars;
close all;
fs = 16000;
N = 258; 

tmax = 2;
t2 = [0: 1/fs: tmax];
noise = randn(fs*tmax, 1);

[simin,nbsecs,fs] = initparams(noise,fs);
sim('recplay');
recv_noise = simout.signals.values;

ymin = -100;
ymax = -35;

% Spectrogram figure
figure('Name', 'Spectrogram');
subplot(2, 1, 1);
noise_sig = [zeros(fs*2,1); noise; zeros(fs*1,1)];
spectrogram(noise_sig, N, round(0.9*N), N, fs, 'yaxis');
title('Transmitted signal');

subplot(2, 1, 2);
spectrogram(recv_noise, N, round(0.9*N), N, fs, 'yaxis');
title('Received signal');

% PSD figure
figure('Name', 'PSD');
subplot(2, 1, 1);
pwelch(noise,N,round(0.8*N),N, fs);
ax = gca();
ylim(ax, [ymin ymax]);
title('Transmitted signal');

subplot(2, 1, 2);
pwelch(recv_noise,N,round(0.8*N),N, fs);
ax = gca();
ylim(ax, [ymin ymax]);
title('Received signal');


%% Exercise 2.1: A first attempt to estimate the channel response
%IR1 estimation


d = [1; zeros(fs*1, 1)];
[simin,nbsecs,fs]=initparams(d,fs);
sim('recplay');
h_IR1 = simout.signals.values;

for i = 1: size(h_IR1, 1)
    
end

% figure()
% plot([1:size(h_IR1, 1)], h_IR1)

start = find(h_IR1 > 0.1, 1)-10;
% start = 2*fs;
h_IR1_cropped = h_IR1(start: start+400, 1);
h_IR1_cropped = h_IR1_cropped / max(h_IR1_cropped);

%save('impulse_response.mat','h_IR1_cropped')



figure('Name', 'IR1 estimation');
t = [1: size(h_IR1_cropped,1)]/fs;
x = [1: size(h_IR1_cropped,1)];

subplot(2, 1, 1)
plot(x, h_IR1_cropped)
xlabel('Samples')
subplot(2, 1, 2)
F = fft(h_IR1_cropped, N);
F = F(1:N/2, 1);

x = [1: size(F, 1)]*fs/N;
semilogy(x, abs(F))

%% Exercise 2.2: A robust channel response estimation
% IR2 estimation

k = 400; %set ht dimension

u = noise(1000:3050, 1);

% find minimal value to find start index
% figure()
% plot([1:size(recv_noise, 1)], recv_noise)
% 
% figure()
% plot([1:size(noise, 1)], noise)

offset = 0;
start_IR2 = find(recv_noise > 0.1, 1) + offset;

y2 = recv_noise(start_IR2+1000: start_IR2+3000, 1);
y = [zeros(50,1); y2];

% figure()
% plot([1:2001], y2)

[h_ir2, H_ir2] = IR2(k, fs, N, u, y);

%% Exercise 1-3 (Elite): Your best friend Shannon
disp("Channel capacity:")
disp(compute_shannon_func(400, 16000, 512))


%% Exercise 2-3 (Elite): Channel response estimation without full excitation

range = [700 3000]/(fs/2);
bandstop = bandstop_filter(fs, range);

for n = 1:1
    k = 400;
    u = noise;
    
    IR_bandstop(bandstop, fs, k, N, u);
    
end






