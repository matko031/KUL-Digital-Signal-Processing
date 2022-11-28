function modulated = qam_mod(sequence, M)
    modulated = qammod(sequence, M, 'InputType','bit', 'UnitAveragePower',true);
end