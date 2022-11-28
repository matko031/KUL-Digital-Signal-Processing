function demod = qam_demod_adaptive(mod, b, nbits)

    demod = [];
    
    first = 1;
    disp("Running Qam_demomod_adaptive...");
    while first <= size(mod, 1)
        k = 1;
        while k <= size(b,1)
            
            M = 2^b(k);
            b(k);
            
            if b(k) > 0
            
                demod_bits = qam_demod(mod(first), M);
                demod = [demod; demod_bits];

                first = first + 1;
            end
            
            k = k+1;
            
            
            if first > size(mod,1)
                break
            end
        end
    end
    disp("Done Qam_demomod_adaptive...");


    % remove padding
    padding_removed = demod(nbits+1: end);
    if size(padding_removed, 1) > 0
        demod = demod(1:nbits);
    end
end
