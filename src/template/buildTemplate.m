function [s,meta] = buildTemplate(x,fs,startSample,endSample,opts)
%BUILDTEMPLATE Select and condition a sample interval from a recording.
if nargin<5, opts=struct; end
x=x(:); n=numel(x);
if startSample<1||endSample>n||startSample~=round(startSample)||endSample~=round(endSample)||endSample<=startSample
 error('buildTemplate:Range','Require integer 1 <= startSample < endSample <= signal length.'); end
[s,pm]=preprocessSignal(x(startSample:endSample),fs,opts);
if numel(s)<2||mean(abs(s).^2)<=eps, error('buildTemplate:Silent','Selected template is silent or too short.'); end
meta=struct('sampleRateHz',fs,'startSample',startSample,'endSample',endSample,'lengthSamples',numel(s), ...
 'energy',sum(abs(s).^2),'meanPower',mean(abs(s).^2),'preprocessing',pm,'sourceEventType','user_selected');
end
