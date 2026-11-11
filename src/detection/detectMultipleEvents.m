function events = detectMultipleEvents(out,threshold,minSeparationSamples)
%DETECTMULTIPLEEVENTS Find threshold crossings and suppress nearby peaks.
if nargin<3, minSeparationSamples=1; end
y=out.correlation(:); cand=find(y>=threshold); if isempty(cand), events=[]; return; end
% Peak candidates only, then greedy strongest-first separation.
isPeak=[true; y(2:end)>=y(1:end-1)] & [y(1:end-1)>=y(2:end); true]; cand=cand(isPeak(cand));
[~,ord]=sort(y(cand),'descend'); chosen=[];
for i=ord(:)'
 k=cand(i); if isempty(chosen)||all(abs(out.startSamples(k)-out.startSamples(chosen))>=minSeparationSamples), chosen(end+1)=k; end %#ok<AGROW>
end
chosen=sort(chosen); events=struct('startSample',num2cell(out.startSamples(chosen)), ...
 'arrivalTimeSeconds',num2cell((out.startSamples(chosen)-1)/out.sampleRateHz), 'score',num2cell(y(chosen)));
end
