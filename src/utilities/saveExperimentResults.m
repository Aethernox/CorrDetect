function saveExperimentResults(baseName,result)
%SAVEEXPERIMENTRESULTS Export a result struct to MAT and a flat summary CSV.
if nargin~=2||~isstruct(result), error('saveExperimentResults:Input','Supply output base name and result struct.'); end
[folder,name]=fileparts(baseName); if isempty(folder), folder=pwd; end
if ~isfolder(folder), mkdir(folder); end
save(fullfile(folder,[name '.mat']),'result','-v7');
if isfield(result,'detection')
 d=result.detection; truth=NaN; targetSnr=NaN; if isfield(result,'groundTruth'), truth=result.groundTruth.startSample; targetSnr=result.groundTruth.targetSNRdB; end
 err=NaN; if isfinite(truth), err=d.estimatedStartSample-truth; end
 fs=NaN; if isfield(result,'sampleRateHz'), fs=result.sampleRateHz; end
 runtime=NaN; if isfield(result,'detectionRuntimeSeconds'), runtime=result.detectionRuntimeSeconds; end
 row=table(string(name),string(d.algorithm),targetSnr,d.score,d.threshold,d.detected,d.estimatedStartSample, ...
 truth,err,d.estimatedArrivalTime,fs,runtime, ...
 'VariableNames',{'experimentId','algorithm','targetSNRdB','score','threshold','detected','estimatedStartSample', ...
 'groundTruthStartSample','timingErrorSamples','estimatedArrivalTimeSeconds','sampleRateHz','runtimeSeconds'});
 writetable(row,fullfile(folder,[name '.csv']));
end
end
