function info = inspectDataset(folder)
%INSPECTDATASET Summarize audio files and their actual WAV metadata.
files=[dir(fullfile(folder,'**','*.wav')); dir(fullfile(folder,'**','*.WAV'))];
info=repmat(struct('file','','sampleRate',NaN,'channels',NaN,'samples',NaN,'durationSeconds',NaN),numel(files),1);
for k=1:numel(files)
 f=fullfile(files(k).folder,files(k).name); a=audioinfo(f);
 info(k)=struct('file',f,'sampleRate',a.SampleRate,'channels',a.NumChannels,'samples',a.TotalSamples,'durationSeconds',a.Duration);
end
end
