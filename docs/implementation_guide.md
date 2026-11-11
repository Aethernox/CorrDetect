# Implementation guide

## Bring your recordings

Run `addpath('scripts'); downloadDataset` to fetch the official TensorFlow Speech Commands v0.02 training and separate test archives, or place user-provided WAV recordings under `data/raw`. The importer reads actual sample rate and channel metadata. Use a keyword-labeled WAV as the reference and a different recording as receiver background. Dataset labels are source labels; injected receiver events are not naturally occurring annotations.

## Run a baseline injection

In MATLAB:

```matlab
cd('path-to/crosscorr_detector')
addpath(genpath(fullfile(pwd,'src')))
addpath(fullfile(pwd,'scripts'))
result = runBaselineExperiment('reference.wav','background.wav',-5,1729);
```

An optional fifth argument is a cell array of separate noise-only WAV paths. Calibration trials match the receiver length and use non-overlapping noise windows without replacement; the helper defaults to the Speech Commands `_background_noise_` folder when present. It errors if the supplied recordings cannot provide 300 such windows. Windows from one long track may still share slow environmental changes. Without noise recordings the threshold remains explicitly uncalibrated.

Alternatively launch `main` and select a reference interval and background in the dashboard. The current demonstration has an uncalibrated threshold until noise-only trials are supplied; do not report that status as calibrated detection.

To exercise the pipeline without external data, add `scripts` to the MATLAB path and run `runSyntheticDemo`. The generated chirp and Gaussian noise are simulation fixtures, not speech recordings.

## Calibrate and evaluate

Load noise-only recordings at the desired receiver duration, create a trial cell array with `generateNoiseOnlyTrials`, then run `estimateThreshold(trials,template,Fs,0.01,'normalized')`. Reserve distinct backgrounds/trials for `evaluateDetector`. Use `generateROC` with independent target-present and noise-only score arrays. Store seeds, files, threshold metadata, and resulting metrics with each report.

## Toolbox behavior

When Signal Processing Toolbox is present, selected bandpass filtering and Welch PSD are used. Otherwise no requested filter is silently substituted and PSD falls back to a windowed periodogram. Core correlation, FFT correlation, simulation, threshold calibration, and evaluation use base MATLAB.
