function qam = estimate_qam(M, val)
    bits = qamdemod(val, M, 'OutputType','bit', 'UnitAveragePower',true);
    qam = qammod(bits, M, 'InputType','bit', 'UnitAveragePower',true);
end

