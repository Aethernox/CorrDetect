function results = runAllTests()
%RUNALLTESTS Execute deterministic core validation suite.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(root,'src')));
tests={@testLagConvention,@testNoiseFreeDetection,@testSNRScaling,@testFFTCorrelation, ...
 @testNormalizedCorrelation,@testThresholdCalibration,@testNoiseOnlyPfa,@testMultipleEvents,@testReproducibility,@testBlockBoundary};
names=cellfun(@func2str,tests,'UniformOutput',false); passed=false(size(tests)); messages=cell(size(tests));
for k=1:numel(tests)
 try
  feval(tests{k}); passed(k)=true; messages{k}='PASS';
 catch e, messages{k}=['FAIL: ' e.message];
 end
 fprintf('%-32s %s\n',names{k},messages{k});
end
results=table(string(names(:)),passed(:),string(messages(:)),'VariableNames',{'test','passed','result'});
out=fullfile(root,'results','metrics'); if ~isfolder(out), mkdir(out); end
writetable(results,fullfile(out,'test_results.csv'));
if ~all(passed), error('runAllTests:Failed','%d of %d tests failed.',sum(~passed),numel(tests)); end
end
function [s,x] = fixture()
rng(54); win=0.5-0.5*cos(2*pi*(0:62)'/62); s=sin(2*pi*(0:62)'/17).*win; x=zeros(500,1); x(213:275)=s;
end
function testLagConvention()
[s,x]=fixture(); o=runCorrelationDetector(x,s,8000); assert(o.estimatedStartSample==213); assert(o.lags(o.peakIndex)==212);
end
function testNoiseFreeDetection()
[s,x]=fixture(); o=runMatchedFilter(x,s,8000); assert(o.estimatedStartSample==213); assert(o.score>0);
end
function testSNRScaling()
rng(2); b=0.2*randn(1000,1); s=randn(80,1); [~,~,m]=injectTemplate(b,s,16000,-7,99,401); assert(abs(m.achievedSNRdB+7)<1e-10);
end
function testFFTCorrelation()
[s,x]=fixture(); a=runCorrelationDetector(x,s,8000); b=runFFTCorrelation(x,s,8000); c=runMatchedFilter(x,s,8000); assert(max(abs(a.correlation-b.correlation))<1e-9); assert(max(abs(a.correlation-c.correlation))<1e-9); assert(a.estimatedStartSample==b.estimatedStartSample&&a.estimatedStartSample==c.estimatedStartSample);
end
function testNormalizedCorrelation()
[s,x]=fixture(); x=4*x; o=runNormalizedCorrelation(x,s,8000); assert(o.estimatedStartSample==213,sprintf('start=%d',o.estimatedStartSample)); assert(o.score>0.99&&o.score<=1+1e-10,sprintf('score=%0.17g',o.score)); z=zeros(100,1); q=runNormalizedCorrelation([z;x],s,8000); assert(all(isfinite(q.correlation)),'normalized correlation contains non-finite values');
end
function testThresholdCalibration()
rng(4); s=randn(25,1); n=cell(100,1); for k=1:numel(n), n{k}=randn(250,1); end
c=estimateThreshold(n,s,1000,.05,'normalized'); assert(c.calibrated&&c.trials==100&&isfinite(c.threshold));
end
function testNoiseOnlyPfa()
rng(14); s=randn(30,1); cal=cell(200,1); holdout=cell(200,1);
for k=1:200, cal{k}=randn(400,1); holdout{k}=randn(400,1); end
c=estimateThreshold(cal,s,1000,.05,'normalized'); m=evaluateNoiseOnly(s,holdout,1000,c.threshold,'normalized'); assert(m.Pfa<=.12);
end
function testMultipleEvents()
[s,~]=fixture(); x=zeros(600,1); x(100:162)=s; x(400:462)=s; o=runNormalizedCorrelation(x,s,8000); e=detectMultipleEvents(o,.9,100); starts=[]; if ~isempty(e), starts=[e.startSample]; end; assert(numel(e)==2,sprintf('count=%d starts=%s',numel(e),mat2str(starts))); assert(isequal(starts,[100 400]),sprintf('starts=%s',mat2str(starts)));
end
function testReproducibility()
b=randn(300,1); s=randn(30,1); [x,a]=injectTemplate(b,s,8000,-3,77); [y,c]=injectTemplate(b,s,8000,-3,77); assert(isequal(x,y)&&a.startSample==c.startSample);
end
function testBlockBoundary()
rng(91); s=randn(41,1); x=0.1*randn(700,1); x(287:327)=x(287:327)+s; a=runNormalizedCorrelation(x,s,8000); b=runStreamCorrelation(x,s,8000,120,Inf,'normalized'); assert(a.estimatedStartSample==287&&b.estimatedStartSample==287); assert(numel(a.correlation)==numel(b.correlation)); assert(max(abs(a.correlation-b.correlation))<1e-12);
end
