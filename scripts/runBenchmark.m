function report = runBenchmark(template,background,fs,repetitions)
%RUNBENCHMARK Compare detector runtimes/results on one receiver.
if nargin<4,repetitions=3;end
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
report=benchmarkAlgorithms(background,template,fs,background,repetitions);
end
