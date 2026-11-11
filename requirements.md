# Requirements

- MATLAB R2019b or newer is recommended. The available installation metadata identifies MATLAB R2026b Update 1 (26.2.0.3433840).
- MATLAB base: file I/O, FFT, plotting, and `uifigure` dashboard (dashboard requires a MATLAB release supporting `uifigure`).
- Signal Processing Toolbox is optional. If available, preprocessing uses `butter`, `filtfilt`, and `pwelch`; otherwise filtering is skipped with metadata and PSD uses a periodogram fallback.
- No Statistics and Machine Learning Toolbox, Parallel Computing Toolbox, or Python dependency is required.
- Speech Commands v0.02 is optional and downloaded separately. The original archive is large; sufficient disk space and network access are required.

The authoring environment contained `D:\MATLAB\bin\matlab.exe`, but `matlab -batch` exited at startup with `System Error: File system inconsistency`. The installation's top-level toolbox folders did not include Signal Processing, Statistics and Machine Learning, or Parallel Computing; runtime/license availability could not be queried. A working MATLAB installation is required for executing `.m` code.
