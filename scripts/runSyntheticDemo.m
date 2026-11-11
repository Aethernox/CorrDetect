function report = runSyntheticDemo(seed,trialCount)
%RUNSYNTHETICDEMO Reproducible algorithm demonstration with labeled synthetic data.
% This is an algorithm fixture, not a real recording or Speech Commands sample.
if nargin<1, seed=1729; end; if nargin<2, trialCount=100; end
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(root,'src'))); addpath(fullfile(root,'config'));
cfg=experimentConfig(); fs=8000; n=4096; m=320; rng(seed,'twister');
t=(0:m-1)'/fs; envelope=0.5-0.5*cos(2*pi*(0:m-1)'/(m-1));
s=(sin(2*pi*(600*t+400*t.^2)).*envelope); s=s-mean(s);
calCount=max(300,ceil(1/cfg.falseAlarmProbability)); calibration=cell(calCount,1);
for k=1:calCount, calibration{k}=randn(n,1); end
cal=estimateThreshold(calibration,s,fs,cfg.falseAlarmProbability,'normalized');
noiseTest=cell(trialCount,1); for k=1:trialCount, noiseTest{k}=randn(n,1); end
noiseEval=evaluateNoiseOnly(s,noiseTest,fs,cal.threshold,'normalized'); noiseScores=noiseEval.scores;
backgrounds=cell(trialCount,1); for k=1:trialCount, backgrounds{k}=randn(n,1); end
snrLevels=cfg.snrLevelsDb; rows=cell(numel(snrLevels),1); targetScores=cell(numel(snrLevels),1);
for k=1:numel(snrLevels)
 rows{k}=evaluateDetector(s,backgrounds,fs,snrLevels(k),cal.threshold,trialCount,seed+100*k,'normalized');
 targetScores{k}=rows{k}.scores;
end
idx=find(snrLevels==cfg.targetSNRdB,1); if isempty(idx), idx=4; end
roc=generateROC(noiseScores,targetScores{idx}); pfa=noiseEval.Pfa;
pd=arrayfun(@(z)z.metrics.Pd,[rows{:}]); mae=arrayfun(@(z)z.metrics.meanAbsoluteTimingErrorSamples,[rows{:}]);
algorithms={'direct','fft','matched-filter','normalized','whitened'}; algResults=cell(numel(algorithms),1); algPfa=zeros(numel(algorithms),1);
for k=1:numel(algorithms)
 if strcmp(algorithms{k},'normalized'), cMode='normalized'; elseif strcmp(algorithms{k},'whitened'), cMode='whitened'; else, cMode='raw'; end
 if strcmp(cMode,'whitened'), c=estimateThreshold(calibration,s,fs,cfg.falseAlarmProbability,cMode,calibration{1}); else, c=estimateThreshold(calibration,s,fs,cfg.falseAlarmProbability,cMode); end
 if strcmp(algorithms{k},'whitened'), algResults{k}=evaluateDetector(s,backgrounds,fs,snrLevels(idx),c.threshold,trialCount,seed+900*k,algorithms{k},calibration{1});
 else, algResults{k}=evaluateDetector(s,backgrounds,fs,snrLevels(idx),c.threshold,trialCount,seed+900*k,algorithms{k}); end
 if strcmp(algorithms{k},'whitened'), nv=evaluateNoiseOnly(s,noiseTest,fs,c.threshold,'whitened',calibration{1});
 else, nvMode=algorithms{k}; if strcmp(nvMode,'matched-filter'), nvMode='raw'; end; nv=evaluateNoiseOnly(s,noiseTest,fs,c.threshold,nvMode); end
 algPfa(k)=nv.Pfa;
end
algorithmComparison=table(string(algorithms(:)),cellfun(@(q)q.metrics.Pd,algResults), ...
 algPfa,cellfun(@(q)q.metrics.meanAbsoluteTimingErrorSamples,algResults),cellfun(@(q)q.metrics.runtimeSeconds,algResults), ...
 'VariableNames',{'algorithm','Pd','Pfa','meanAbsoluteTimingErrorSamples','meanRuntimeSeconds'});
resultsDir=fullfile(root,'results','metrics'); figuresDir=fullfile(root,'results','figures');
if ~isfolder(resultsDir),mkdir(resultsDir);end; if ~isfolder(figuresDir),mkdir(figuresDir);end
metrics=table(snrLevels(:),pd(:),1-pd(:),mae(:),repmat(pfa,numel(snrLevels),1), ...
 'VariableNames',{'snrDb','Pd','missRate','meanAbsoluteTimingErrorSamples','heldOutNoisePfa'});
writetable(metrics,fullfile(resultsDir,'synthetic_demo_metrics.csv'));
writetable(algorithmComparison,fullfile(resultsDir,'synthetic_algorithm_comparison.csv'));
fig=figure('Visible','off'); plot(snrLevels,pd,'o-','LineWidth',1.5); grid on; xlabel('SNR (dB)'); ylabel('Probability of Detection'); title('Synthetic controlled injection'); saveas(fig,fullfile(figuresDir,'synthetic_pd_vs_snr.png')); close(fig);
fig=figure('Visible','off'); plot(roc.Pfa,roc.Pd,'LineWidth',1.5); grid on; xlabel('False Alarm Probability'); ylabel('Detection Probability'); title(sprintf('Synthetic ROC at %g dB; AUC %.4f',snrLevels(idx),roc.AUC)); saveas(fig,fullfile(figuresDir,'synthetic_roc.png')); close(fig);
fig=figure('Visible','off'); plot(snrLevels,mae,'o-','LineWidth',1.5); grid on; xlabel('SNR (dB)'); ylabel('Mean absolute timing error (samples)'); title('Synthetic timing error'); saveas(fig,fullfile(figuresDir,'synthetic_timing_error.png')); close(fig);
calThresholds=sort(cal.calibrationScores); pfaCurve=arrayfun(@(z)mean(cal.calibrationScores>=z),calThresholds);
fig=figure('Visible','off'); plot(calThresholds,pfaCurve); grid on; xlabel('Threshold'); ylabel('Calibration Pfa'); title('Noise-only calibration curve'); saveas(fig,fullfile(figuresDir,'synthetic_pfa_vs_threshold.png')); close(fig);
receiver=backgrounds{1}; [receiver,~,~]=injectTemplate(receiver,s,fs,cfg.targetSNRdB,seed+17,round(n/2));
runtimeTable=benchmarkAlgorithms(receiver,s,fs,backgrounds{1},3); writetable(runtimeTable,fullfile(resultsDir,'synthetic_runtime_benchmark.csv'));
fig=figure('Visible','off'); bar(categorical(runtimeTable.algorithm),runtimeTable.medianRuntimeSeconds); grid on; ylabel('Median runtime (s)'); title('Synthetic detector runtime'); saveas(fig,fullfile(figuresDir,'synthetic_runtime.png')); close(fig);
fig=figure('Visible','off'); bar(categorical(algorithmComparison.algorithm),algorithmComparison.Pd); grid on; ylabel('Probability of Detection'); title(sprintf('Synthetic algorithm comparison at %g dB',snrLevels(idx))); saveas(fig,fullfile(figuresDir,'synthetic_algorithm_comparison.png')); close(fig);
report=struct('dataType','synthetic_gaussian_noise_plus_synthetic_chirp_template','seed',seed, ...
 'sampleRateHz',fs,'template',s,'calibration',cal,'snrLevelsDb',snrLevels,'perSNR',{rows}, ...
 'metrics',metrics,'rocAtTargetSNR',roc,'heldOutNoisePfa',pfa,'heldOutNoiseEvaluation',noiseEval, ...
 'algorithmComparison',algorithmComparison,'runtimeBenchmark',runtimeTable);
save(fullfile(resultsDir,'synthetic_demo.mat'),'report','-v7');
end
