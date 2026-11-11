# Testing and validation status

## Test suite

`tests/runAllTests.m` defines ten MATLAB tests for lag convention, noiseless exact timing, SNR scaling, direct/FFT/matched-filter agreement, normalized scores and zero-energy windows, noise-only threshold calibration and held-out Pfa, multiple events, seeded reproducibility, and a block-boundary event. It writes `results/metrics/test_results.csv` when executable.

## Environment result

On 2026-11-01 the installed command resolved to `D:\MATLAB\bin\matlab.exe`; `VersionInfo.xml` identifies MATLAB R2026b Update 1. `matlab -batch` startup and the batch version/toolbox query terminated with `System Error: File system inconsistency`. The installation tree had no Signal Processing, Statistics and Machine Learning, or Parallel Computing toolbox directories, but license/product resolution could not be queried.

The user ran the MATLAB suite in an interactive session. Before the latest fix, 8 of 10 tests passed; `testNormalizedCorrelation` and `testMultipleEvents` failed. The normalized detector now computes numerator and window energy from the same valid-window alignment and enforces the Cauchy-Schwarz score bound. The affected tests now print score/start details on failure. These changes have not yet been rerun in MATLAB, so the suite is not claimed as passing.

The standalone `mlint.exe` MATLAB Code Analyzer parsed every `.m` file with no diagnostics after cleanup. This is static analysis only; it does not execute functions, resolve toolbox dependencies, or exercise UI behavior.

Rerun the suite after the normalized-correlation changes with `addpath('tests'); runAllTests` from the project root. Real-data performance still requires separate noise calibration and held-out test recordings.

## Planned validation still needed

The changed normalized detector and event-selection tests need a rerun. Additional validation remains for stereo/resampling fixtures, dashboard interaction/export, colored-noise whitening efficacy, memory benchmarking across lengths, and held-out real-data multi-SNR ROC/Pd/Pfa. The synthetic script implements ROC, runtime, timing, Pd/Pfa, and algorithm comparison outputs but has not been run in MATLAB.

An independent NumPy/SciPy numerical check (not execution of MATLAB source) verified direct versus zero-padded FFT correlation and one-based insertion mapping, plus block overlap coverage and normalized-score equality on a boundary-crossing fixture. These checks support the equations but do not count as MATLAB test passes.
