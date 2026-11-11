function report = benchmarkAlgorithms(x,s,fs,noise,repetitions)
%BENCHMARKALGORITHMS Time detector modes on identical signals and inputs.
if nargin<4||isempty(noise), noise=x; end
if nargin<5, repetitions=3; end
if ~isscalar(repetitions)||~isfinite(repetitions)||repetitions<1||repetitions~=round(repetitions), error('benchmarkAlgorithms:Repetitions','repetitions must be a positive integer.'); end
names={'direct','matched-filter','fft','normalized','whitened-normalized','streaming-normalized'};
fns={@()runCorrelationDetector(x,s,fs,Inf,'raw'),@()runMatchedFilter(x,s,fs,Inf), ...
 @()runFFTCorrelation(x,s,fs,Inf,'raw'),@()runNormalizedCorrelation(x,s,fs,Inf), ...
 @()runWhiteningDetector(x,s,fs,noise,Inf),@()runStreamCorrelation(x,s,fs,max(numel(s),floor(numel(x)/4)),Inf,'normalized')};
runtime=zeros(numel(fns),1); score=zeros(size(runtime)); start=zeros(size(runtime)); outputBytes=zeros(size(runtime));
for k=1:numel(fns)
 fns{k}(); % warm up code path
 times=zeros(repetitions,1);
 for r=1:repetitions, t=tic; o=fns{k}(); times(r)=toc(t); end
 runtime(k)=median(times); score(k)=o.score; start(k)=o.estimatedStartSample;
 outputBytes(k)=8*numel(o.correlation); if ~isreal(o.correlation), outputBytes(k)=16*numel(o.correlation); end
end
report=table(string(names(:)),runtime,score,start,outputBytes, ...
 'VariableNames',{'algorithm','medianRuntimeSeconds','peakScore','estimatedStartSample','correlationOutputBytes'});
end
