function [a, b, H1, H2, H12] = fixed_transmitter_side_beamformer(h1, h2, N)
    H1 = fft(h1, N);
    H2 = fft(h2, N);
    
    H12 = sqrt(H1 .* conj(H1) + H2 .* conj(H2));
    
    a = conj(H1) ./ sqrt(H1.*conj(H1) + H2.*conj(H2));
    b = conj(H2) ./ sqrt(H1.*conj(H1) + H2.*conj(H2));
    
end