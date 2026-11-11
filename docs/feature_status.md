# Feature status

## Implemented, awaiting MATLAB execution

- WAV import with actual metadata, channel downmix, and explicit resampling (polyphase when available; documented interpolation fallback).
- Selected-interval template processing and MAT save.
- Seeded local-SNR injection with exact one-based ground truth.
- Valid-window direct correlation, matched filtering, linear FFT correlation, normalized scoring, regularized whitening, multiple-event peak separation, and overlap-block processing.
- Empirical noise-only threshold calibration and held-out Monte Carlo evaluation APIs.
- Synthetic reproducibility demo, ROC generation, Pd/timing/Pfa figures, and detector runtime/output-size benchmark.
- Programmatic UI for loading WAV files, selecting algorithms/SNR/trials, plotting waveform and score response, and MAT/CSV export.

## Implemented but not tested in MATLAB

MATLAB Code Analyzer reports no diagnostics across all source files. The user executed the test suite: 8 passed and 2 failed before the latest normalized-correlation fix; the modified tests are awaiting rerun. Dashboard interaction, full toolbox resolution, and measured performance remain unverified in this workspace.

## Planned or incomplete

The displayed injection equation in the user prompt has an inverted SNR ratio; code uses the mathematically consistent equation documented in `mathematical_foundation.md`.

- Download/import of Speech Commands and populated real-data manifest (the dataset is absent and network access is restricted).
- Reading/extracting the supplied PDF's content (no PDF extraction utility was installed; installing one was blocked by network policy).
- End-to-end validation on real recordings and measured real-data Pd/Pfa, ROC, timing, runtime, and memory.
- Dashboard threshold-calibration workflow from distinct noise-only files, persistent experiment log table, dataset selector, and complete performance analytics panels.
- UI automation and GUI export validation; stereo/resampling automated fixtures; nonstationary-noise CFAR; memory benchmark; filtering/spectrogram pre/post views.
