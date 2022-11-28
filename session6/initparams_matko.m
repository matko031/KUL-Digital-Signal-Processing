function [simin,nbsecs,fs]=initparams(toplay,fs, pulse, IR_length)
% toplay: Nx1 vector, signal to be played
% fs: scalar, sampling frequency

% scale signal between -1 and 1
if max(toplay) > 0
    toplay = toplay / max(toplay);
end

% add 2 second of silence at the beginning and one at the end
start_padding = zeros(fs*2, 1);
end_padding = zeros(fs, 1);
simin = [
    start_padding start_padding;
    pulse pulse;
    zeros(IR_length, 1) zeros(IR_length, 1);
    toplay toplay;
    end_padding end_padding
     ];
 
% calculate the length of the signal
simin_size = size(simin);
rows = simin_size(1);
nbsecs = rows / fs;
end

