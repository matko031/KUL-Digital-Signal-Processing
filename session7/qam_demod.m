function demodulated = qam_demod(seq, M)
    demodulated = qamdemod(seq, M, 'OutputType','bit', 'UnitAveragePower',true);
end