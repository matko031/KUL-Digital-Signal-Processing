function visualise_demod(received, h, H, t)

[~, transmitted, colorMap, ~] = imagetobitstream('image.bmp');

t_axis = [1: size(h, 1)]';
f_axis = [1: size(H, 1)]';
t = num2str(round(t*1000, 2));

subplot(2,2,1); plot(t_axis, h); title('Estimated channel impulse response');
subplot(2,2,2); colormap(colorMap); image(transmitted); axis image; title('Transmitted image'); drawnow;
subplot(2,2,3); semilogy(f_axis, abs(H)); title('Estimated channel frequency response (amplitude)');
subplot(2,2,4); colormap(colorMap); image(received); axis image; title(['Received image after ' t ' ms']); drawnow;

end