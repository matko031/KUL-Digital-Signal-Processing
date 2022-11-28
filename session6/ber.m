function ratio = ber(seq_in, seq_out)
    %size(seq_in), size(seq_out)
    
    dif = seq_out - seq_in;
    errors = nnz(dif);
    ratio = errors/size(seq_in, 1);
end