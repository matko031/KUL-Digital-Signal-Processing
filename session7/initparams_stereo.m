function [simin,nbsecs,fs] = initparams_stereo(toplay_L, toplay_R, fs, pulse, IR_length)
    toplay_L = toplay_L / max(toplay_L);
    toplay_R = toplay_R / max(toplay_R);

    start_padding = zeros(fs*2, 1);
    end_padding = zeros(fs, 1);
    simin = [
        start_padding start_padding;
        pulse pulse;
        zeros(IR_length, 1) zeros(IR_length, 1);
        toplay_L toplay_R;
        end_padding end_padding
         ];

    simin_size = size(simin);
    rows = simin_size(1);
    nbsecs = rows / fs;
end

