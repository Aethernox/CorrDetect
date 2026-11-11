function out = runFFTCorrelation(x,s,fs,threshold,mode)
%RUNFTTCORRELATION Zero-padded FFT linear cross-correlation.
if nargin<4, threshold=Inf; end
if nargin<5, mode='raw'; end
x=x(:); s=s(:); N=numel(x); M=numel(s); if M>N, error('runFFTCorrelation:Length','Template exceeds receiver length.'); end
if M<1||N<1||~isfinite(fs)||fs<=0, error('runFFTCorrelation:Input','Signals must be nonempty and Fs positive finite.'); end
L=2^nextpow2(N+M-1); z=ifft(fft(x,L).*fft(conj(flipud(s)),L)); c=z(M:N); lags=(0:N-M)';
if strcmpi(mode,'normalized')
 e=conv(abs(x).^2,ones(M,1)); e=e(M:N); c=abs(c)./(sqrt(max(e,0))*norm(s)+eps); c=min(c,1);
else
 c=abs(c);
end
[peak,ix]=max(c); start=lags(ix)+1;
out=struct('score',peak,'correlation',c,'lags',lags,'startSamples',lags+1, ...
 'estimatedStartSample',start,'estimatedArrivalTime',(start-1)/fs,'peakIndex',ix, ...
 'peakAmplitude',peak,'threshold',threshold,'detected',peak>=threshold,'algorithm','fft-correlation','mode',mode,'sampleRateHz',fs);
end
