function c_channel = compute_shannon_func(f, fs, N)
    options = simset('SrcWorkspace','current');

    K = floor(N / 2);
    tmax = 2;
    t = [0:1/fs:tmax]';
    sig = sin(2*pi*f*t);
    silence = zeros(size(t,1), 1);
    
    
    [simin,nbsecs,fs] = initparams(sig,fs);
    sim('recplay', [], options);
    out_sig_n=simout.signals.values;


    [simin,nbsecs,fs]=initparams(silence, fs);
    sim('recplay', [], options);
    out_n=simout.signals.values;


    sig = [zeros(fs*2, 1); sig; zeros(fs, 1)];


    psd_sig_n = pwelch(out_sig_n, N, round(0.9*N), N, fs);
    psd_n = pwelch(out_n, N, round(0.9*N), N, fs);
    psd_sig = psd_sig_n - psd_n;


%     figure(1);
%     zoom on;
%     f = 1: N : size(psd_sig,1)*N;
%     semilogy(f, psd_sig_n, 'DisplayName','psd\_sig\_n')
%     hold on;
%     semilogy(f, psd_n, 'DisplayName','psd\_n')
%     semilogy(f, psd_sig, 'DisplayName','psd\_sig');
%     hold off;
%     legend;


    c_channel = 0;
    for k = 1: K
       ps = psd_sig(k);
       pn = psd_n(k);
       c_channel = c_channel + log2(1 + ps/pn);
    end
    c_channel = c_channel * fs/N;
end


