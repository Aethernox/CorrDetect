function trials = generateNoiseOnlyTrials(noiseRecordings,trialLength,count,seed)
%GENERATENOISEONLYTRIALS Draw random windows from supplied noise-only recordings.
% Windows are non-overlapping within each input recording. Distinct windows
% from one recording can still be statistically dependent due to slow drift.
if nargin<4, seed=1; end
if ~isscalar(trialLength)||~isfinite(trialLength)||trialLength<1||trialLength~=round(trialLength)|| ...
   ~isscalar(count)||~isfinite(count)||count<1||count~=round(count)
 error('generateNoiseOnlyTrials:Count','trialLength and count must be positive integers.');
end
if isnumeric(noiseRecordings), noiseRecordings={noiseRecordings}; end
if ~iscell(noiseRecordings)||isempty(noiseRecordings), error('generateNoiseOnlyTrials:Input','Provide one or more noise-only recordings.'); end
for k=1:numel(noiseRecordings)
 noiseRecordings{k}=noiseRecordings{k}(:);
 if numel(noiseRecordings{k})<trialLength, error('generateNoiseOnlyTrials:Length','Every recording must be at least trialLength samples.'); end
end
rng(seed,'twister'); sourceIds=[]; starts=[];
for j=1:numel(noiseRecordings)
 candidates=1:trialLength:(numel(noiseRecordings{j})-trialLength+1);
 sourceIds=[sourceIds;repmat(j,numel(candidates),1)]; starts=[starts;candidates(:)]; %#ok<AGROW>
end
if numel(starts)<count, error('generateNoiseOnlyTrials:Capacity','Need %d non-overlapping windows but only %d fit; add longer or more noise-only recordings.',count,numel(starts)); end
order=randperm(numel(starts)); order=order(1:count); trials=cell(count,1);
for k=1:count
 j=sourceIds(order(k)); start=starts(order(k)); src=noiseRecordings{j}; trials{k}=src(start:start+trialLength-1);
end
end
