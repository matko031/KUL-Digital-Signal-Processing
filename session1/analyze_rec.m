clear all;
fs = 16000;
N = 1024;
t = 2;

x = [0:1/fs:t];
n = randn(1, size(x,2));


% sig = 0;
% frequencies = [100 200 500 1000 1500 2000 4000 6000];
% sig = 0;
% for i = 1:size(frequencies, 2)
%     sig = sig + sin(2*pi*frequencies(i)*x);
% end

sig = n;

sig1 = sig;
sig1 = [zeros(1, fs*2) sig1 zeros(1, fs)];

play = true;
if play
    [simin,nbsecs,fs]=initparams(sig,fs);
    sim('recplay');
    out=simout.signals.values;
    sig2 = out;
else
    sig2 = sig;
end



figure(1)
subplot(2, 1, 1);
spectrogram(sig1, N, round(0.9*N), N, fs, 'yaxis');
subplot(2, 1, 2);
spectrogram(sig2, N, round(0.9*N), N, fs, 'yaxis');




figure(2)
subplot(2, 1, 1);
pwelch(sig1,N,round(0.8*N),N, fs);
subplot(2, 1, 2);
pwelch(sig2,N,round(0.8*N),N, fs);

