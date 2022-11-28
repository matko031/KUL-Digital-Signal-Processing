function H_full = interpolate(H_orig)

    M = size(H_orig,1);
    N = M;

    H_zeros = zeros(2*M, 1);
    H_zeros(1:2:2*M) = H_orig;
    
    h_orig = ifft(H_orig, N);
    h_zeros = ifft(H_zeros, N);


    figure(1)
    subplot(2,1,1)
    t_H_orig = 1:2:2*M;
    plot(t_H_orig, H_orig, '-o', Color='blue');
    hold on
    t_H_zeros = 1:2*M;
    plot(t_H_zeros, H_zeros, '-x', Color = 'red');
    hold off
    xticks(t_H_zeros)
    legend('H original','H zeros')

    subplot(2,1,2)
    t_h_orig = 1:2:2*M;
    plot(t_h_orig, abs(h_orig), '-o', Color='blue');
    hold on
    t_h_zeros = 1:2: 2*M;
    plot(t_h_zeros, abs(h_zeros), '-x', Color = 'red');
    hold off

    legend('h original','h zeros')


%     H(2:2:end) = 0;
%     h = ifft(H, N/2);
%     h = h(1:floor(N/2));
%     H_full = fft(h, N/2);
%     
%     figure(1)
%     xH = 1: 2: size(H);
%     plot(xH, H(H>0), '-o', Color='blue');
%     hold on
%     xHfull = 1:size(H_full);
%     plot(xHfull, abs(H_full), Color = 'red');
%     
%     legend('H original','H\_full')
% 
%     hold off
end

