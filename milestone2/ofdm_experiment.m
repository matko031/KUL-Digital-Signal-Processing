clearvars;

i = 6;

n = 1024;
p = 2;

N = (n/2 - 1) * p;

M = 2^i;

seq = randi([0 1], i * N, 1);

modulated = ofdm_mod_F(seq, n, p, M);

demodulated = ofdm_demod_F(modulated, n, p, M);

ber(seq, demodulated)
