function [simin,nbsecs,fs]=initparams(toplay,fs)
% toplay: Nx1 vector
% fs: scalar

if max(toplay) > 0
    toplay = toplay / max(toplay);
end
start_padding = zeros(fs*2, 1);
end_padding = zeros(fs, 1);
simin = [
    start_padding start_padding;
    toplay toplay;
    end_padding end_padding
     ];
simin_size = size(simin);
rows = simin_size(1);
nbsecs = rows / fs;
end

