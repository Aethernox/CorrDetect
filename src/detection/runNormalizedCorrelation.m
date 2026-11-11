function out = runNormalizedCorrelation(x,s,fs,threshold)
%RUNNORMALIZEDCORRELATION Amplitude-invariant valid-window correlation.
if nargin<4, threshold=Inf; end
out=runCorrelationDetector(x,s,fs,threshold,'normalized'); out.algorithm='normalized-correlation';
end
