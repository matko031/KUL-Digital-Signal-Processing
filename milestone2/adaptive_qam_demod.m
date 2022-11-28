 function demod = adaptive_qam_demod(mod, H, P, G, nbits)

    b = floor(log2(1 +  abs(H).^2 ./ (G*P)));
    
    demod = [];
    
    first = 1;
    while first <= size(mod, 1)
        k = 1;
        while k <= size(b,1)
            
            M = 2^b(k);
            b(k);
            
            if b(k) > 0
            
                demod_bits = qam_demod(mod(first), M);
                demod = [demod; demod_bits];
 
%             else
%                 mod(first)
%                 demod_bit = round(mod(first))
%                 demod = [demod; demod_bit];
                first = first + 1;
            end
            
            k = k+1;
            
            
            if first > size(mod,1)
                break
            end
        end
    end
    
    % remove padding
    padding_removed = demod(nbits+1: end);
    if size(padding_removed, 1) > 0
        demod = demod(1:nbits);
    end
end
