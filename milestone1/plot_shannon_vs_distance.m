n = 5;
c = zeros(n, 1);
for i = 1:n
    disp(i)
    c(i) = compute_shannon_func(400, 16000, 512);
end

plot([1:n]', c);