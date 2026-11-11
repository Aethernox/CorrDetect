function [pxx,f] = estimateNoisePSD(x,fs,nfft)
%ESTIMATENOISEPSD Welch PSD where available; periodogram fallback otherwise.
if nargin<3||isempty(nfft), nfft=2^nextpow2(min(numel(x),4096)); end
x=x(:);
if ~isreal(x)
    nfft=max(nfft,numel(x)); X=fft(x,nfft); pxx=abs(X).^2/(fs*numel(x));
    f=(0:nfft-1)'*fs/nfft; f(f>=fs/2)=f(f>=fs/2)-fs;
    return
end
if exist('pwelch','file')==2
 [pxx,f]=pwelch(x,[],[],nfft,fs);
else
 n=min(numel(x),nfft); w=0.5-0.5*cos(2*pi*(0:n-1)'/max(n-1,1)); X=fft(x(1:n).*w,nfft);
 pxx=abs(X(1:floor(nfft/2)+1)).^2/(fs*sum(w.^2)); f=(0:floor(nfft/2))'*fs/nfft;
end
end
