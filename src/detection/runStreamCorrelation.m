function out = runStreamCorrelation(x,s,fs,blockSize,threshold,mode)
%RUNSTREAMCORRELATION Correlate in blocks with M-1 overlap and global indexing.
if nargin<4||isempty(blockSize), blockSize=65536; end
if nargin<5, threshold=Inf; end
if nargin<6, mode='normalized'; end
x=x(:); s=s(:); N=numel(x); M=numel(s);
if ~isscalar(blockSize)||~isfinite(blockSize)||blockSize<1||blockSize~=round(blockSize), error('runStreamCorrelation:BlockSize','blockSize must be a positive integer.'); end
if blockSize<M, error('runStreamCorrelation:BlockSize','blockSize must be at least the template length.'); end
if M>N, error('runStreamCorrelation:Length','Template exceeds receiver length.'); end
allC=[]; allStarts=[]; carry=[]; cursor=1;
while cursor<=N
 stop=min(N,cursor+blockSize-1); new=x(cursor:stop); segment=[carry;new]; segmentStart=cursor-numel(carry);
 if numel(segment)>=M
  if strcmpi(mode,'normalized'), part=runNormalizedCorrelation(segment,s,fs); else, part=runCorrelationDetector(segment,s,fs,Inf,'raw'); end
  starts=segmentStart+part.startSamples-1;
  allC=[allC;part.correlation(:)]; allStarts=[allStarts;starts(:)]; %#ok<AGROW>
 end
 keep=min(M-1,numel(segment)); carry=segment(end-keep+1:end); cursor=stop+1;
end
[peak,ix]=max(allC); start=allStarts(ix);
out=struct('score',peak,'correlation',allC,'lags',allStarts-1,'startSamples',allStarts, ...
 'estimatedStartSample',start,'estimatedArrivalTime',(start-1)/fs,'peakIndex',ix, ...
 'peakAmplitude',peak,'threshold',threshold,'detected',peak>=threshold,'algorithm','streaming-correlation', ...
 'mode',mode,'sampleRateHz',fs);
end
