# Architecture

The system is divided into dataset I/O, preprocessing, template creation, controlled simulation, detectors, threshold calibration, evaluation, visualization, and UI. The detector functions do not depend on the UI.

`loadSignal` reads the WAV metadata and downmixes by arithmetic mean; resampling is requested explicitly. `buildTemplate` selects a one-based sample interval and stores energy and preprocessing metadata. `injectTemplate` chooses a reproducible valid delay and scales the template from the local background power. Detection functions return only valid starting positions, the one-based estimated start, zero-based lag, peak score, threshold decision, and time.

The calibration function accepts noise-only trials and estimates a quantile of trial maximum scores. The trial generator takes non-overlapping windows without replacement from supplied noise recordings; temporal dependence may still remain within one long source file. Keep noise recordings, calibration trials, and test trials separate. `evaluateDetector` performs controlled injection into supplied background recordings. The UI is a programmatic `uifigure` front end; importing/exporting and detector logic are MATLAB functions.

Original recordings belong in `data/raw`; derived receiver files and experiment metadata belong in `data/processed`; templates and manifests have dedicated folders. Artificial injections are explicitly tagged in ground truth.
