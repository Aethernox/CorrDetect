function out = runMatchedFilter(x,s,fs,threshold)
%RUNMATCHEDFILTER Matched filter with exact valid-window start mapping.
if nargin<4, threshold=Inf; end
x=x(:); s=s(:); M=numel(s); N=numel(x);
if M<1||N<1||~isfinite(fs)||fs<=0, error('runMatchedFilter:Input','Signals must be nonempty and Fs positive finite.'); end
if M>N, error('runMatchedFilter:Length','Template exceeds receiver length.'); end
h=conj(flipud(s)); y=conv(x,h); c=abs(y(M:N)); lags=(0:N-M)';
[peak,ix]=max(c); start=lags(ix)+1;
out=struct('score',peak,'correlation',c,'lags',lags,'startSamples',lags+1, ...
 'estimatedStartSample',start,'estimatedArrivalTime',(start-1)/fs,'peakIndex',ix, ...
 'peakAmplitude',peak,'threshold',threshold,'detected',peak>=threshold,'algorithm','matched-filter','mode','raw','sampleRateHz',fs);
end
