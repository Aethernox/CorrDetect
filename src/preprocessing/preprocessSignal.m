function [y,meta] = preprocessSignal(x,fs,opts)
%PREPROCESSSIGNAL Apply selected conditioning consistently to template/data.
if nargin<3, opts=struct; end
if ~isvector(x)||isempty(x)||~isnumeric(x), error('preprocessSignal:Input','x must be a non-empty numeric vector.'); end
if ~isscalar(fs)||~isfinite(fs)||fs<=0, error('preprocessSignal:Fs','fs must be positive and finite.'); end
x=x(:); y=x; meta=struct('removedMean',0,'detrended',false,'bandpassHz',[],'filterApplied',false);
if ~isfield(opts,'removeMean')||opts.removeMean, meta.removedMean=mean(y); y=y-meta.removedMean; end
if isfield(opts,'detrend')&&opts.detrend, y=detrend(y); meta.detrended=true; end
if isfield(opts,'bandpassHz')&&~isempty(opts.bandpassHz)
 bp=opts.bandpassHz;
 if numel(bp)~=2||bp(1)<=0||bp(2)>=fs/2||bp(1)>=bp(2), error('preprocessSignal:Band','Bandpass must satisfy 0 < low < high < Fs/2.'); end
 if exist('butter','file')==2&&exist('filtfilt','file')==2
  [b,a]=butter(4,bp/(fs/2),'bandpass'); y=filtfilt(b,a,y); meta.filterApplied=true;
 else
  warning('preprocessSignal:NoToolbox','Signal Processing Toolbox unavailable; bandpass skipped.');
 end
 meta.bandpassHz=bp;
end
meta.rms=sqrt(mean(abs(y).^2)); meta.peak=max(abs(y)); meta.energy=sum(abs(y).^2);
end
