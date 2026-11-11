function cal = estimateThreshold(noiseTrials,template,fs,pfa,mode,noiseModel)
%ESTIMATETHRESHOLD Calibrate a max-score threshold from noise-only trials.
if nargin<4, pfa=0.01; end
if nargin<5, mode='normalized'; end
if ~isscalar(pfa)||~isfinite(pfa)||pfa<=0||pfa>=1, error('estimateThreshold:Pfa','pfa must be between zero and one.'); end
if ~iscell(noiseTrials), error('estimateThreshold:Trials','noiseTrials must be a cell array.'); end
if isempty(noiseTrials), error('estimateThreshold:Trials','At least one noise-only trial is required.'); end
if ~any(strcmpi(mode,{'normalized','raw','whitened'})), error('estimateThreshold:Mode','mode must be normalized, raw, or whitened.'); end
scores=zeros(numel(noiseTrials),1);
trialLength=numel(noiseTrials{1});
if trialLength<numel(template), error('estimateThreshold:Length','Noise trials must be at least as long as the template.'); end
for k=1:numel(noiseTrials)
 if ~isvector(noiseTrials{k})||numel(noiseTrials{k})~=trialLength, error('estimateThreshold:Length','All noise trials must be vectors of equal length.'); end
 if strcmpi(mode,'normalized')
  o=runNormalizedCorrelation(noiseTrials{k},template,fs);
 elseif strcmpi(mode,'whitened')
  if nargin<6||isempty(noiseModel), model=noiseTrials{k}; else, model=noiseModel; end
  o=runWhiteningDetector(noiseTrials{k},template,fs,model,Inf);
 else
  o=runCorrelationDetector(noiseTrials{k},template,fs,Inf,'raw');
 end
 scores(k)=o.score;
end
sorted=sort(scores); idx=max(1,min(numel(sorted),ceil((1-pfa)*(numel(sorted)+1))));
cal=struct('threshold',sorted(idx),'targetPfa',pfa,'calibrationScores',scores, ...
 'empiricalPfaAtThreshold',mean(scores>=sorted(idx)),'trials',numel(scores),'mode',mode, ...
 'calibrated',true,'method','empirical upper quantile of noise-only maximum scores');
end
