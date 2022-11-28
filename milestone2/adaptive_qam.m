 function [qams, b] = adaptive_qam(sig, H, P, G)

    qams = [];
    
    b = floor(log2(1 +  abs(H).^2 ./ (G*P)));

    first = 1;
    while first <= size(sig, 1)
        % qams = [qams zeros(size(H,1), 1)];
        for i = 1: size(b,1)
            
            if b(i) > 0
                M = 2^b(i);
                
                last = min(first+b(i)-1, size(sig,1));

                seg = sig(first: last, :);
                
                if last < (first+b(i)-1)
                    padding = zeros(first+b(i)-1 - size(sig,1),1);
                    seg = [seg; padding];
                end
                
                seg_mod = qam_mod(seg, M);
                
                qams = [qams; seg_mod;];
                first = first + b(i);
             
                
%             else
%                 qams = [qams; sig(first)];
%                 first = first + 1;
            end
            
            if first > size(sig,1)
                break
            end
            
        end
    end
end


