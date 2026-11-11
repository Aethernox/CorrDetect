function out = runCorrelationDetector(x,s,fs,threshold,mode)
%RUNCORRELATIONDETECTOR Linear direct correlation over valid template starts.
if nargin<4, threshold=Inf; end
if nargin<5, mode='raw'; end
if isempty(x)||isempty(s)||~isvector(x)||~isvector(s)||fs<=0, error('runCorrelationDetector:Input','Receiver/template must be nonempty vectors and Fs positive.'); end
x=x(:); s=s(:);
if strcmpi(mode,'normalized')
    % Use the same explicit valid-window alignment for numerator and energy.
    N=numel(x); M=numel(s);
    if M>N, error('runCorrelationDetector:Length','Template exceeds receiver length.'); end
    c=conv(x,conj(flipud(s))); c=c(M:N); lags=(0:N-M)';
else
    [c,lags]=linearCorr(x,s,'direct');
end
out=pack(c,lags,x,s,fs,threshold,mode,'direct');
end
function [c,lags]=linearCorr(x,s,method)
N=numel(x); M=numel(s); if M>N, error('runCorrelationDetector:Length','Template exceeds receiver length.'); end
if strcmp(method,'direct') && exist('xcorr','file')==2
 [z,l]=xcorr(x,s); % xcorr lags map start offset; retrieve all valid placements 0..N-M
 keep=(l>=0 & l<=N-M); c=z(keep); lags=l(keep);
else
 c=conv(x,conj(flipud(s))); lags=(0:N-M)'; c=c(M:N);
end
end
function o=pack(c,lags,x,s,fs,threshold,mode,algorithm)
if strcmpi(mode,'normalized')
 e=conv(abs(x).^2,ones(numel(s),1)); e=e(numel(s):numel(x));
 c=abs(c)./(sqrt(max(e,0))*norm(s)+eps);
 c=min(c,1); % Cauchy-Schwarz upper bound; removes floating-point overshoot.
else
 c=abs(c);
end
[peak,ix]=max(c); start=lags(ix)+1;
o=struct('score',peak,'correlation',c,'lags',lags(:),'startSamples',lags(:)+1, ...
 'estimatedStartSample',start,'estimatedArrivalTime',(start-1)/fs,'peakIndex',ix, ...
 'peakAmplitude',peak,'threshold',threshold,'detected',peak>=threshold,'algorithm',algorithm,'mode',mode,'sampleRateHz',fs);
end
