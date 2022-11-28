clearvars;
N = 1026;
M = 16;
fs = 16000;
Hk = 5+ 5i;
delta = 10^-3;
Wk = 1 / conj(Hk) + delta;
P = 1000;

bits = randi([0 1], sqrt(M)*P, 1);
X = qam_mod(bits, M);

mu = 0.05;
alpha = 10^-5;
e = zeros(P,1);
Y = Hk*X;
out = zeros(P,1);

for k=1:P
    out = conj(Wk)*Y(k,1); % why is this so?
    
    u = Y(k,1);
    d = X(k,1); % this should be an estimate
    e(k) = abs(conj(Wk) - 1/Hk);
    Wk = Wk + (mu / (alpha + conj(u)*u)) * u * conj(d - conj(Wk)*u);

end

plot(abs(e));