function [x,fs,meta] = loadSignal(fileName,targetFs)
%LOADSIGNAL Import audio, downmix channels, and optionally resample.
arguments
    fileName (1,1) string
    targetFs (1,1) double = NaN
end
if ~isfile(fileName), error('loadSignal:NotFound','Audio file not found: %s',fileName); end
if ~(isnan(targetFs)||isfinite(targetFs)&&targetFs>0), error('loadSignal:TargetFs','targetFs must be positive finite or NaN.'); end
[x,fs] = audioread(fileName);
meta = struct('sourceFile',char(fileName),'originalFs',fs,'originalChannels',size(x,2), ...
    'originalSamples',size(x,1),'originalDurationSeconds',size(x,1)/fs,'resampled',false);
if size(x,2)>1, x=mean(x,2); end
if ~isnan(targetFs) && targetFs~=fs
    if exist('resample','file')==2
        [p,q]=rat(targetFs/fs,1e-12); x=resample(x,p,q);
    else
        % Base-MATLAB linear interpolation fallback; lower fidelity than polyphase resampling.
        oldT=(0:numel(x)-1)'/fs; newT=(0:1/targetFs:oldT(end))'; x=interp1(oldT,x,newT,'linear');
    end
    fs=targetFs; meta.resampled=true;
end
meta.outputFs=fs; meta.outputSamples=numel(x); meta.outputDurationSeconds=numel(x)/fs;
end
