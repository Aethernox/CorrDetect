function cfg = experimentConfig()
%EXPERIMENTCONFIG Default reproducible experiment parameters.
cfg.targetSNRdB = -5;
cfg.snrLevelsDb = [-20 -15 -10 -5 0 5 10];
cfg.seed = 1729;
cfg.calibrationTrials = 300;
cfg.testTrials = 100;
cfg.falseAlarmProbability = 0.01;
cfg.detector = 'normalized';
cfg.preprocessing = struct('removeMean',true,'detrend',false,'bandpassHz',[]);
cfg.datasetName = 'user-supplied WAV';
end
