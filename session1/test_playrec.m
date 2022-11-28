clear all;
fs = 16000;
f = 1500;
t = 2;
x = [0:1/fs:t];
sinewave = sin(2*pi*f*x)';
[simin,nbsecs,fs]=initparams(sinewave,fs);
sim('recplay');
out=simout.signals.values;

[simin,nbsecs,fs]=initparams(out,fs);
sim('recplay');