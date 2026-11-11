function [y,gt,meta] = injectTemplate(background,template,fs,snrDb,seed,startSample)
%INJECTTEMPLATE Insert a template at a controlled SNR in local background.
if nargin<5||isempty(seed), seed=1; end
background=background(:); template=template(:); n=numel(background); m=numel(template);
if isempty(background)||isempty(template)||~isfinite(fs)||fs<=0||~isfinite(snrDb), error('injectTemplate:Input','Signals must be nonempty; Fs must be positive and SNR finite.'); end
if m>n, error('injectTemplate:Length','Template must fit inside background.'); end
if nargin<6||isempty(startSample), rng(seed,'twister'); startSample=randi(n-m+1); end
if startSample<1||startSample+m-1>n||startSample~=round(startSample), error('injectTemplate:Index','Insertion index is outside valid range.'); end
seg=background(startSample:startSample+m-1); pNoise=mean(abs(seg).^2); pTemplate=mean(abs(template).^2);
if pTemplate<=eps, error('injectTemplate:Template','Template has zero energy.'); end
if pNoise<=eps, error('injectTemplate:Noise','Local background power is zero; cannot set SNR.'); end
% For SNR=10*log10(Psignal/Pnoise), the target power ratio multiplies
% background power. The inverse-ratio form would reverse the requested dB sign.
alpha=sqrt(pNoise*10^(snrDb/10)/pTemplate); y=background; y(startSample:startSample+m-1)=seg+alpha*template;
gt=struct('eventType','artificial_injection','startSample',startSample,'arrivalTimeSeconds',(startSample-1)/fs, ...
 'targetSNRdB',snrDb,'randomSeed',seed,'alpha',alpha);
meta=struct('backgroundLocalPower',pNoise,'templateMeanPower',pTemplate,'achievedSNRdB', ...
 10*log10(mean(abs(alpha*template).^2)/pNoise));
end
