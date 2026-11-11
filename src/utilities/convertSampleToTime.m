function t = convertSampleToTime(sample,fs)
%CONVERTSAMPLETOTIME Convert one-based MATLAB sample index to time in seconds.
if fs<=0||any(sample(:)<1), error('convertSampleToTime:Input','Require positive Fs and one-based samples.'); end
t=(sample-1)./fs;
end
