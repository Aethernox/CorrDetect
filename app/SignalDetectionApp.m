classdef SignalDetectionApp < handle
%SIGNALDETECTIONAPP Compact interactive UI wired to the MATLAB detection engine.
properties
 Figure; WaveAxes; CorrAxes; Status; ThresholdField; SNRField; AlgorithmDropDown; TrialField; Template; TemplateMetadata; Background; OriginalBackground; Fs; TemplateFile; BackgroundFile; LastResult;
end
methods
 function app=SignalDetectionApp()
  app.Figure=uifigure('Name','Cross-Correlation Signal Detection','Position',[100 100 1050 680]);
  grid=uigridlayout(app.Figure,[3 4]); grid.RowHeight={82,34,'1x'}; grid.ColumnWidth={160,160,160,'1x'};
  b=uibutton(grid,'Text','Load reference WAV','ButtonPushedFcn',@(~,~)app.loadReference()); b.Layout.Row=1;b.Layout.Column=1;
  b=uibutton(grid,'Text','Load background WAV','ButtonPushedFcn',@(~,~)app.loadBackground()); b.Layout.Row=1;b.Layout.Column=2;
  b=uibutton(grid,'Text','Run injection + detect','ButtonPushedFcn',@(~,~)app.runExperiment()); b.Layout.Row=1;b.Layout.Column=3;
  panel=uipanel(grid,'Title','Experiment'); panel.Layout.Row=1; panel.Layout.Column=4;
  pg=uigridlayout(panel,[5 2]); pg.ColumnWidth={'1x','1x'}; pg.RowHeight={14,14,14,14,18};
  uilabel(pg,'Text','SNR dB'); app.SNRField=uieditfield(pg,'numeric','Value',-5); app.SNRField.Layout.Row=1; app.SNRField.Layout.Column=2;
  uilabel(pg,'Text','Threshold*'); app.ThresholdField=uieditfield(pg,'numeric','Value',Inf); app.ThresholdField.Layout.Row=2; app.ThresholdField.Layout.Column=2;
  uilabel(pg,'Text','Algorithm'); app.AlgorithmDropDown=uidropdown(pg,'Items',{'normalized','direct','fft','matched-filter','whitened'},'Value','normalized'); app.AlgorithmDropDown.Layout.Row=3; app.AlgorithmDropDown.Layout.Column=2;
  uilabel(pg,'Text','Trials'); app.TrialField=uieditfield(pg,'numeric','Limits',[1 Inf],'Value',1); app.TrialField.Layout.Row=4; app.TrialField.Layout.Column=2;
  b=uibutton(pg,'Text','Export MAT + CSV','ButtonPushedFcn',@(~,~)app.exportResult()); b.Layout.Row=5;b.Layout.Column=[1 2];
  viz=uipanel(grid,'Title','Receiver and detector response'); viz.Layout.Row=3; viz.Layout.Column=[1 4];
  vg=uigridlayout(viz,[1 2]); vg.ColumnWidth={'1x','1x'};
  app.WaveAxes=uiaxes(vg); app.CorrAxes=uiaxes(vg);
  app.Status=uilabel(grid,'Text','Load separate reference and background WAV files. *A threshold must be calibrated on independent noise-only recordings.');
  app.Status.Layout.Row=2; app.Status.Layout.Column=[1 4];
 end
 function loadReference(app)
  [f,p]=uigetfile('*.wav','Select reference recording'); if isequal(f,0),return,end
  [x,fs]=audioread(fullfile(p,f)); app.Fs=fs; if size(x,2)>1,x=mean(x,2);end
  answer=inputdlg({'Start time (s)','End time (s)'},'Select template interval',[1 35],{'0.1','0.6'}); if isempty(answer),return,end
  [template,templateMetadata]=buildTemplate(x,app.Fs,max(1,round(str2double(answer{1})*app.Fs)+1),min(numel(x),round(str2double(answer{2})*app.Fs)),struct); app.Template=template; app.TemplateMetadata=templateMetadata;
  app.TemplateFile=fullfile(p,f); app.Status.Text=sprintf('Reference loaded: %s (%d samples)',f,numel(app.Template));
 end
 function loadBackground(app)
  [f,p]=uigetfile('*.wav','Select receiver background recording'); if isequal(f,0),return,end
  if isempty(app.Fs), uialert(app.Figure,'Load the reference first to establish the detector sample rate.','Reference required'); return; end
  [background,fb]=loadSignal(string(fullfile(p,f)),app.Fs); app.OriginalBackground=background; [processedBackground,~]=preprocessSignal(background,app.Fs,struct('removeMean',true)); app.Background=processedBackground; app.BackgroundFile=fullfile(p,f);
  app.Status.Text=sprintf('Background loaded: %s at %g Hz',f,fb);
 end
 function runExperiment(app)
  if isempty(app.Template)||isempty(app.Background),uialert(app.Figure,'Load a reference and a background first.','Missing input');return,end
  try
   [y,gt,sm]=injectTemplate(app.Background,app.Template,app.Fs,app.SNRField.Value,1729);
   algorithm=app.AlgorithmDropDown.Value;
   detectTimer=tic;
   switch algorithm
    case 'normalized', o=runNormalizedCorrelation(y,app.Template,app.Fs,app.ThresholdField.Value);
    case 'direct', o=runCorrelationDetector(y,app.Template,app.Fs,app.ThresholdField.Value,'raw');
    case 'fft', o=runFFTCorrelation(y,app.Template,app.Fs,app.ThresholdField.Value,'raw');
    case 'matched-filter', o=runMatchedFilter(y,app.Template,app.Fs,app.ThresholdField.Value);
    case 'whitened', o=runWhiteningDetector(y,app.Template,app.Fs,app.Background,app.ThresholdField.Value);
   end
   multi=[];
   if app.TrialField.Value>1, multi=evaluateDetector(app.Template,{app.Background},app.Fs,app.SNRField.Value,app.ThresholdField.Value,app.TrialField.Value,1729,algorithm); end
   detectionRuntimeSeconds=toc(detectTimer);
   app.LastResult=struct('groundTruth',gt,'snr',sm,'detection',o,'detectionRuntimeSeconds',detectionRuntimeSeconds,'multiTrial',multi,'template',app.Template, ...
    'backgroundOriginal',app.OriginalBackground,'backgroundPreprocessed',app.Background,'receiverInjected',y, ...
    'templateMetadata',app.TemplateMetadata,'templateFile',app.TemplateFile,'backgroundFile',app.BackgroundFile,'sampleRateHz',app.Fs);
   plotWaveforms(app.WaveAxes,y,app.Fs,'Injected receiver (truth and estimate)'); hold(app.WaveAxes,'on'); xline(app.WaveAxes,o.estimatedArrivalTime,'r--','Estimated'); xline(app.WaveAxes,gt.arrivalTimeSeconds,'g:','Truth'); hold(app.WaveAxes,'off');
   plotCorrelation(app.CorrAxes,o);
   if isempty(multi), extra=''; else, extra=sprintf(' | Pd %.3f | MAE %.2f samples',multi.metrics.Pd,multi.metrics.meanAbsoluteTimingErrorSamples); end
   app.Status.Text=sprintf('%s | estimated %.4f s | target %.4f s | error %+d samples%s | threshold uncalibrated',char(string(o.detected)),o.estimatedArrivalTime,gt.arrivalTimeSeconds,o.estimatedStartSample-gt.startSample,extra);
   catch e
    uialert(app.Figure,e.message,'Experiment failed');
   end
 end
 function exportResult(app)
  if isempty(app.LastResult), uialert(app.Figure,'Run an experiment before exporting.','No result'); return; end
  root=fileparts(fileparts(mfilename('fullpath'))); out=fullfile(root,'results','metrics','latest_experiment');
  try
   saveExperimentResults(out,app.LastResult); app.Status.Text=['Exported: ' out '.mat and .csv'];
  catch e
   uialert(app.Figure,e.message,'Export failed');
  end
 end
end
end
