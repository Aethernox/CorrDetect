function saveExperimentResults(outBasePath, result)
%SAVEEXPERIMENTRESULTS Save experiment results structure to MAT and CSV.
[outDir, baseName] = fileparts(outBasePath);
if ~isempty(outDir) && ~isfolder(outDir), mkdir(outDir); end

% Save full structured result to .mat
save([outBasePath '.mat'], 'result', '-v7');

% Extract tabular summary fields for .csv export
algorithm = "unknown";
if isfield(result, 'detection') && isfield(result.detection, 'algorithm')
    algorithm = string(result.detection.algorithm);
end

targetSNRdB = NaN;
if isfield(result, 'groundTruth') && isfield(result.groundTruth, 'targetSNRdB')
    targetSNRdB = result.groundTruth.targetSNRdB;
elseif isfield(result, 'snr') && isfield(result.snr, 'achievedSNRdB')
    targetSNRdB = result.snr.achievedSNRdB;
end

score = NaN; threshold = NaN; detected = 0; estimatedStart = NaN; arrivalTime = NaN; Fs = NaN;
if isfield(result, 'detection')
    score = result.detection.score;
    threshold = result.detection.threshold;
    detected = double(result.detection.detected);
    estimatedStart = result.detection.estimatedStartSample;
    arrivalTime = result.detection.estimatedArrivalTime;
    if isfield(result.detection, 'sampleRateHz')
        Fs = result.detection.sampleRateHz;
    end
end
if isnan(Fs) && isfield(result, 'sampleRateHz')
    Fs = result.sampleRateHz;
end

gtStart = NaN;
if isfield(result, 'groundTruth') && isfield(result.groundTruth, 'startSample')
    gtStart = result.groundTruth.startSample;
end

timingError = estimatedStart - gtStart;
runtimeSeconds = NaN;
if isfield(result, 'detectionRuntimeSeconds')
    runtimeSeconds = result.detectionRuntimeSeconds;
end

t = table(string(baseName), algorithm, targetSNRdB, score, threshold, detected, ...
    estimatedStart, gtStart, timingError, arrivalTime, Fs, runtimeSeconds, ...
    'VariableNames', {'experimentId','algorithm','targetSNRdB','score','threshold','detected', ...
    'estimatedStartSample','groundTruthStartSample','timingErrorSamples','estimatedArrivalTimeSeconds', ...
    'sampleRateHz','runtimeSeconds'});
writetable(t, [outBasePath '.csv']);
end

