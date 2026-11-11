function result = evaluateDetector(template,backgrounds,fs,snrDb,threshold,trials,seed,mode,noiseModel)
%EVALUATEDETECTOR Monte Carlo controlled-injection evaluation.
if nargin<8, mode='normalized'; end
if ~iscell(backgrounds), backgrounds={backgrounds}; end
if isempty(backgrounds)||trials<1||trials~=round(trials), error('evaluateDetector:Input','Provide backgrounds and a positive integer trial count.'); end
for j=1:numel(backgrounds), if ~isvector(backgrounds{j})||isempty(backgrounds{j}), error('evaluateDetector:Background','Each background must be a non-empty vector.'); end, end
rng(seed,'twister'); det=false(trials,1); est=nan(trials,1); truth=zeros(trials,1); rt=zeros(trials,1); scores=zeros(trials,1);
for k=1:trials
 b=backgrounds{mod(k-1,numel(backgrounds))+1}(:); [x,g]=injectTemplate(b,template,fs,snrDb,seed+k,[]); truth(k)=g.startSample;
 t=tic;
 switch lower(mode)
  case 'normalized', o=runNormalizedCorrelation(x,template,fs,threshold);
  case 'direct', o=runCorrelationDetector(x,template,fs,threshold,'raw');
  case 'fft', o=runFFTCorrelation(x,template,fs,threshold,'raw');
  case 'matched-filter', o=runMatchedFilter(x,template,fs,threshold);
  case 'whitened'
   if nargin<9||isempty(noiseModel), model=b; else, model=noiseModel; end
   o=runWhiteningDetector(x,template,fs,model,threshold);
  otherwise, error('evaluateDetector:Mode','Unsupported detector mode: %s',mode);
 end
 rt(k)=toc(t);
 det(k)=o.detected; est(k)=o.estimatedStartSample; scores(k)=o.score;
end
metrics=calculateMetrics(det,est,truth,rt); result=struct('metrics',metrics,'detected',det,'estimatedStartSamples',est, ...
 'groundTruthStartSamples',truth,'scores',scores,'snrDb',snrDb,'threshold',threshold,'seed',seed,'mode',mode);
end
