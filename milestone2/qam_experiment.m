clearvars;
n = 1024;

N_q = 6;

snr = 25;

avg_sig_power = [1:N_q];
bit_error_rate = [1:N_q];

for i = 1:N_q
    M = 2^i;
    
    seq = randi([0 1], n*i, 1);

    mod_seq = qam_mod_F(seq, M);
    
    avg_sig_power(i) = mean(mod_seq.^2);
    
    % test for noisy channel:
    out = awgn(mod_seq, snr);

    scatterplot(out)
    grid on;
    
    demod_seq = qam_demod_F(out, M);
    
    bit_error_rate(i) = ber(seq, demod_seq);
end

bit_error_rate
avg_sig_power


