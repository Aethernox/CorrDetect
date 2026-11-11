function out = runWhiteningDetector(x,s,fs,noise,threshold)
%RUNWHITENINGDETECTOR Regularized frequency-domain whitening on both inputs.
if nargin<5, threshold=Inf; end
x=x(:); s=s(:); noise=noise(:);
if isempty(x)||isempty(s)||isempty(noise)||~isfinite(fs)||fs<=0, error('runWhiteningDetector:Input','Receiver, template, and noise model must be nonempty; Fs must be positive finite.'); end
nfft=2^nextpow2(2*max([numel(x),numel(s),numel(noise)]));
[p,f]=estimateNoisePSD(noise,fs,nfft);
% Build a stable inverse square-root spectral weighting and apply circularly
% padded filtering; crop original signal lengths to avoid wrap contamination.
floorP=max(max(p)*1e-8,eps); w=1./sqrt(max(p,floorP));
whiten=@(v) localWhite(v,w,nfft);
xw=whiten(x); sw=whiten(s);
out=runNormalizedCorrelation(xw,sw,fs,threshold); out.algorithm='whitened-normalized-correlation';
out.whitening=struct('noisePSD',p,'frequencyHz',f,'regularizationFloor',floorP);
end
function y=localWhite(x,w,n)
offset=floor((n-numel(x))/2); pad=zeros(n,1,'like',x); pad(offset+(1:numel(x)))=x;
X=fft(pad,n);
if numel(w)==n, wf=w; else, wf=[w;flipud(w(2:end-1))]; wf=wf(1:n); end
y=ifft(X.*wf,n); y=y(offset+(1:numel(x)));
if isreal(x), y=real(y); end
end
