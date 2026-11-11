function plotCorrelation(ax,out)
%PLOTCORRELATION Plot correlation response, estimated peak, and threshold.
plot(ax,(out.startSamples-1)/out.sampleRateHz,out.correlation,'LineWidth',1); hold(ax,'on');
if isfinite(out.threshold), yline(ax,out.threshold,'r--','Threshold'); else, text(ax,0.02,0.95,'Threshold uncalibrated','Units','normalized','Color',[.7 .1 .1]); end
xline(ax,out.estimatedArrivalTime,'k:','Peak'); hold(ax,'off');
xlabel(ax,'Template start time (s)'); ylabel(ax,'Detection score'); title(ax,out.algorithm); grid(ax,'on');
end
