function IR_bandstop(filter_object, fs, k, N, u)

    signal_filtered = filter(filter_object, 1, u);
    signal_filtered_norm = signal_filtered/max(signal_filtered);
    
    figure('Name', 'Filtered noise');
    subplot(2, 1, 1);
    x = [1:size(signal_filtered, 1)];
    plot(x, signal_filtered_norm)
    title('Filtered noise  (t-domain)');

    subplot(2, 1, 2);
    signal_filtered_freq = fft(signal_filtered_norm, N);
    f = [1: N/2]*fs/N;
    semilogy(f', abs(signal_filtered_freq(1:N/2)))
    title('Filtered noise (f-domain)');
    
    len_signal_filtered = size(signal_filtered, 1)
    
    [simin, nbsecs, fs] = initparams(signal_filtered_norm, fs);
    'start sim'
    sim('recplay');
    'end sim'
    out = simout.signals.values;
    
    out = [zeros(50,1); out];
    
    figure()
    plot([1:size(out, 1)], out)
    
    offset = 0;
    start = find(out > 0.1, 2) + offset;
    
    figure()
    plot([1:size(out, 1)], out)
    
    out = out(start: start+len_signal_filtered-1, 1);
    
    [h, H] = IR2(k, fs, N, signal_filtered_norm, out);

end