function roc = generateROC(noiseScores,targetScores)
%GENERATEROC Empirical ROC using independent score samples.
allScores=sort(unique([noiseScores(:);targetScores(:)])); thresholds=[-Inf;allScores;Inf]; Pfa=zeros(size(thresholds)); Pd=Pfa;
for k=1:numel(thresholds), Pfa(k)=mean(noiseScores(:)>=thresholds(k)); Pd(k)=mean(targetScores(:)>=thresholds(k)); end
roc=struct('thresholds',thresholds,'Pfa',Pfa,'Pd',Pd,'AUC',trapz(flipud(Pfa),flipud(Pd)));
end
