%clearvars;

fs = [16000; 44100];
fs = fs(1);

K = 512;
N = 2*K;

t = 2;
f = 400;
x = [0:1/fs:t];
sig = sin(2*pi*f*x);


[simin,nbsecs,fs]=initparams(sig,fs);
sim('recplay');
out_sig_n=simout.signals.values;


[simin,nbsecs,fs]=initparams(zeros(1, size(x,2)), fs);
sim('recplay');
out_n=simout.signals.values;


sig = [zeros(1, fs*2) sig zeros(1, fs)];


psd_sig_n = pwelch(out_sig_n,N,round(0.9*N),N, fs);
psd_n = pwelch(out_n,N,round(0.9*N),N, fs);
psd_sig = psd_sig_n - psd_n;


figure(1);
zoom on;
x_plot = 1: size(psd_sig,1);
semilogy(x_plot, psd_sig_n, 'DisplayName','psd\_sig\_n')
hold on;
semilogy(x_plot, psd_n, 'DisplayName','psd\_n')
semilogy(x_plot, psd_sig, 'DisplayName','psd\_sig');
hold off;
legend;


c_channel = 0;
for k = 1: K
   ps = psd_sig(k);
   pn = psd_n(k);
   c_channel = c_channel + log2(1 + ps/pn);
end
c_channel = c_channel * fs/N;
c_channel

