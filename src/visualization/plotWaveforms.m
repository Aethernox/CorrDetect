function plotWaveforms(ax,x,fs,labelText)
%PLOTWAVEFORMS Plot signal amplitude against time.
if nargin<4,labelText='Signal';end
t=(0:numel(x)-1)/fs; plot(ax,t,x); xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude'); title(ax,labelText); grid(ax,'on');
end
