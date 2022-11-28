function bandstop = bandstop_filter(fs, range)
    order = 48;
    ftype = 'stop';
    bandstop = fir1(order, range, ftype);
    figure('Name', 'Bandstop filter');
    freqz(bandstop,1,512)
    title('Bandstop filter: frequency response (amplitude and phase)');
end