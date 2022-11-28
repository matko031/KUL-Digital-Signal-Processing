 function [qams, b] = qam_mod_adaptive(sig, H, P, G)
    
    b = floor(log2(1 +  abs(H).^2 ./ (G*P)));
    bpf = sum(b);
    qpf = sum(b>0);
    sig_len = size(sig,1);
    nb_frames = ceil( sig_len / bpf );
    qams = zeros( nb_frames*qpf, 1 );

    ind = 1: size(b,1);
    first = 1;
    qam_counter = 1;
    disp("Running Qam_mod_adaptive...");
    i = 1;
    M = b(i);
    while first <= size(sig, 1)
        disp("counter: " + first);

        for i = ind(b>0)
            M = 2^b(i);
%             disp("first: " + first + ", i: " + i +", b(i): " + b(i) + ", M: " + M)
          

            last = min(first+b(i)-1, size(sig,1));

            seg = sig(first: last, :);
            
            if last < (first+b(i)-1)
                padding = zeros(first+b(i)-1 - size(sig,1),1);
                seg = [seg; padding];
            end
            
            seg_mod = qam_mod(seg, M);
            
            qams(qam_counter) = seg_mod;
            qam_counter = qam_counter + 1;
            first = first + b(i);

            if first > size(sig,1)
                break
            end
         
        end
    end
    disp("Done Qam_mod_adaptive...");

end


