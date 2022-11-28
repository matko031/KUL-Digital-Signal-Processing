fs = 16000;
N = 1024;

k = 4000;
n_h = 400;

play = true;
if play
    n = randn(fs*2, 1);
    n = n / max(n);
    [simin,nbsecs,fs] = initparams(n',fs);
    sim('recplay');
    y = simout.signals.values;
    save('noise.mat', 'y', 'n');
else
    load('noise.mat');
end


n = n(1:k, 1);
y = y(1:k, 1);
r1 = [n(1,1) zeros(1, n_h-1)];
c1 = n;
X = toeplitz(c1, r1);
h = X \ y;

t = [1: size(h,1)]/fs;
subplot(2, 1, 1)
plot(t, h)
subplot(2, 1, 2)
F = fft(h, N);
F = F(1:N/2, 1);
f = [1: size(F, 1)]*fs/N;
semilogy(f, abs(F))

