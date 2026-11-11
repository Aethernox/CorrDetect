function metrics = calculateMetrics(detected,estimated,truth,runTimes,noiseDetections)
%CALCULATEMETRICS Compute detection and timing statistics.
detected=logical(detected(:)); estimated=estimated(:); truth=truth(:); Pd=mean(detected);
err=estimated(detected)-truth(detected); Pfa=NaN; if nargin>=5&&~isempty(noiseDetections), Pfa=mean(logical(noiseDetections(:))); end
metrics=struct('Pd',Pd,'Pfa',Pfa,'missRate',1-Pd, ...
 'meanAbsoluteTimingErrorSamples',mean(abs(err),'omitnan'),'stdTimingErrorSamples',std(err,'omitnan'), ...
 'runtimeSeconds',mean(runTimes(:)));
end
