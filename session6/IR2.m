function [h_IR2, H] = IR2(k, fs, N, u, y, plotting)
     %set ht dimension
    r1 = [u(1,1) zeros(1, k-1)];
    c1 = u;
    X = toeplitz(c1, r1);

    h_IR2 = X \ y;
    H2 = fft(h_IR2, N);
    H = H2(1:N/2, 1);
    
    if plotting

        figure('Name','IR2 estimation');
        h = [1: size(h_IR2,1)]/fs;
        x_IR2 = [1: size(h_IR2,1)];

        subplot(2, 1, 1);
        plot(x_IR2, h_IR2)
        title('Channel time response');


        subplot(2, 1, 2);
        f = [1: size(H, 1)]*fs/N;
        semilogy(f, abs(H))
        title('Channel frequency response');
    end
    
    %save('impulse_response.mat','h_IR2', 'H')
end