close all;
clearvars;

n = 1024;

M_max = 16;
i = 1;

lower = 0;
step = 1;
upper = 70;

%avg_sig_power = [1:N_q];
snr_array = [lower:step:upper]';
ber_matrix = zeros((upper-lower)/step, M_max);

figure()
hold on

while i <= M_max
    
    M = 2^i;
    seq = randi([0 1], n*i, 1);
    mod_seq = qam_mod(seq, M);
    
    j = 1;
    for snr = lower:step:upper

        %avg_sig_power(i) = mean(mod_seq.^2);

        % test for noisy channel:
        out = awgn(mod_seq, snr);

        % scatterplot(out)
        %grid on;

        demod_seq = qam_demod(out, M);

        ber_matrix(j, i) = ber(seq, demod_seq);
        
        j = j+1;
    end
    
    plot(snr_array, ber_matrix(:, i));
    
    i = i * 2;
end

legend('2-qam', '4-qam', '8-qam', '16-qam', '32-qam');
title('BER vs. SNR for M-QAM');
xlabel('SNR [dB]');
ylabel('BER');
set(gca,'yscale','log');


