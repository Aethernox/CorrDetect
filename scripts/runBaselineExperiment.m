function result = runBaselineExperiment(templateFile,backgroundFile,snrDb,seed,noiseOnlyFiles)
%RUNBASELINEEXPERIMENT Reproducible WAV-to-injection detector demonstration.
if nargin<3, snrDb=-5; end; if nargin<4, seed=1729; end
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(root,'src')));
if nargin<5||isempty(noiseOnlyFiles)
 noiseDir=fullfile(root,'data','raw','speech_commands_v0.02','_background_noise_');
 f=dir(fullfile(noiseDir,'*.wav')); noiseOnlyFiles=cellfun(@(n)fullfile(noiseDir,n),{f.name},'UniformOutput',false);
end
[ref,fr,refMeta]=loadSignal(string(templateFile)); [bgOriginal,~,bgMeta]=loadSignal(string(backgroundFile),fr);
[bg,bgPrep]=preprocessSignal(bgOriginal,fr,struct('removeMean',true));
% Use a non-silent central interval (caller should choose a labelled word file).
start=max(1,round(0.15*numel(ref))); stop=min(numel(ref),round(0.85*numel(ref)));
[s,tMeta]=buildTemplate(ref,fr,start,stop,struct('removeMean',true));
if numel(bg)<numel(s)+2, error('runBaselineExperiment:Background','Background must be longer than the selected template.'); end
[y,truth,snrMeta]=injectTemplate(bg,s,fr,snrDb,seed);
calibration=[];
if ~isempty(noiseOnlyFiles)
 if ischar(noiseOnlyFiles)||isstring(noiseOnlyFiles), noiseOnlyFiles=cellstr(noiseOnlyFiles); end
 noiseSources=cell(numel(noiseOnlyFiles),1);
 for q=1:numel(noiseOnlyFiles)
  [v,~,~]=loadSignal(string(noiseOnlyFiles{q}),fr); [noiseSources{q},~]=preprocessSignal(v,fr,struct('removeMean',true));
 end
 windowCapacity=sum(floor(cellfun(@numel,noiseSources)/numel(bg)));
 nCalibration=min(300,windowCapacity);
 if nCalibration<100, error('runBaselineExperiment:CalibrationCapacity','Only %d non-overlapping calibration windows fit. Provide longer or more noise-only recordings (at least 100 trials required).',nCalibration); end
 noiseTrials=generateNoiseOnlyTrials(noiseSources,numel(bg),nCalibration,seed+1);
 calibration=estimateThreshold(noiseTrials,s,fr,0.01,'normalized'); threshold=calibration.threshold;
 calibration.sourceFiles=noiseOnlyFiles; calibration.randomSeed=seed+1;
 save(fullfile(root,'data','processed','latest_noise_calibration.mat'),'noiseTrials','calibration','noiseOnlyFiles','-v7.3');
 thresholdStatus=sprintf('calibrated from %d separate noise-only trials',nCalibration);
else
 threshold=Inf; thresholdStatus='uncalibrated: no independent noise-only recordings supplied';
end
detectTimer=tic; detector=runNormalizedCorrelation(y,s,fr,threshold); detectionRuntimeSeconds=toc(detectTimer);
result=struct('referenceFile',refMeta,'backgroundFile',bgMeta,'backgroundPreprocessing',bgPrep,'templateMetadata',tMeta, ...
 'groundTruth',truth,'snrMetadata',snrMeta,'detection',detector,'detectionRuntimeSeconds',detectionRuntimeSeconds,'sampleRateHz',fr, ...
 'timingErrorSamples',detector.estimatedStartSample-truth.startSample, ...
 'thresholdStatus',thresholdStatus,'thresholdCalibration',calibration);
proc=fullfile(root,'data','processed'); if ~isfolder(proc), mkdir(proc); end
saveTemplate(fullfile(root,'data','templates','reference_template.mat'),s,tMeta);
audiowrite(fullfile(proc,'latest_receiver.wav'),y,fr);
save(fullfile(proc,'latest_experiment.mat'),'result','s','y','bg','bgOriginal','truth');
saveExperimentResults(fullfile(root,'results','metrics','latest_baseline'),result);
end
