function validateSignal(x,fs,name)
%VALIDATESIGNAL Assert common signal integrity requirements.
if nargin<3, name='signal'; end
if ~isnumeric(x)||isempty(x)||~isvector(x), error('validateSignal:Vector','%s must be a non-empty numeric vector.',name); end
if ~isscalar(fs)||~isfinite(fs)||fs<=0, error('validateSignal:Fs','%s sampling rate must be a positive finite scalar.',name); end
if any(~isfinite(x)), error('validateSignal:Finite','%s contains NaN or Inf samples.',name); end
end
