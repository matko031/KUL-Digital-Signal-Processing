close all;
clearvars;
fs = 16000;
N = 1024;

play = true;
if play
    d = [1; zeros(fs*1, 1)];
    [simin,nbsecs,fs]=initparams(d,fs);
    sim('recplay');
    ht=simout.signals.values;
    ht = ht(fs*2:fs*2.1, 1);
    save('impulse.mat', 'ht');
else
    load('impulse.mat');
end

x = [1: size(ht,1)]/fs;
subplot(2, 1, 1)
plot(x, ht')
subplot(2, 1, 2)
F = fft(ht, N);
F = F(1:N/2, 1);
x = [1: size(F, 1)]*fs/N;
semilogy(x, abs(F))