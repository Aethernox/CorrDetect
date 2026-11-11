function result = evaluateNoiseOnly(template,noiseTrials,fs,threshold,mode,noiseModel)
%EVALUATENOISEONLY Measure false alarms on held-out noise-only recordings.
if nargin<5, mode='normalized'; end
if ~iscell(noiseTrials)||isempty(noiseTrials), error('evaluateNoiseOnly:Trials','Supply nonempty noise-only trial cell array.'); end
if ~any(strcmpi(mode,{'normalized','raw','direct','fft','whitened'})), error('evaluateNoiseOnly:Mode','Unsupported mode: %s',mode); end
detected=false(numel(noiseTrials),1); scores=zeros(numel(noiseTrials),1); runtime=zeros(numel(noiseTrials),1);
trialLength=numel(noiseTrials{1});
for k=1:numel(noiseTrials)
 x=noiseTrials{k}; if ~isvector(x)||numel(x)~=trialLength||trialLength<numel(template), error('evaluateNoiseOnly:Length','Noise trials must have equal length >= template length.'); end
 t=tic;
 if strcmpi(mode,'normalized')
  o=runNormalizedCorrelation(x,template,fs,threshold);
 elseif strcmpi(mode,'whitened')
  if nargin<6||isempty(noiseModel), model=x; else, model=noiseModel; end
  o=runWhiteningDetector(x,template,fs,model,threshold);
 elseif strcmpi(mode,'fft')
  o=runFFTCorrelation(x,template,fs,threshold,'raw');
 else
  o=runCorrelationDetector(x,template,fs,threshold,'raw');
 end
 runtime(k)=toc(t); scores(k)=o.score; detected(k)=o.detected;
end
result=struct('Pfa',mean(detected),'falseAlarmCount',sum(detected),'trials',numel(detected), ...
 'scores',scores,'detected',detected,'runtimeSeconds',runtime,'threshold',threshold,'mode',mode);
end
