# Mathematical foundation

For receiver `x[n]` and template `s[n]`, the linear correlation at a valid start offset `k` is `r[k] = sum_{m=0}^{M-1} x[k+m] conj(s[m])`. MATLAB's reported sample index is `k+1`; the associated arrival time is `k/Fs`. The matched filter uses `h[n] = conj(s[M-1-n])`; its full convolution output is sampled from index `M` through `N` to align with valid template starts.

The FFT implementation computes the same linear correlation after zero-padding to at least `N+M-1`, preventing circular wraparound. Normalized correlation is `abs(r[k])/(norm(x_window)*norm(s)+eps)` and reduces sensitivity to amplitude changes.

For local background mean power `P_b` and template mean power `P_s`, the scale consistent with `SNR=10 log10(P_signal/P_noise)` is `alpha=sqrt(P_b*10^(gamma/10)/P_s)`. The inverse-ratio formula printed in the supplied prompt contradicts its own SNR definition and yields the opposite dB sign; the implementation follows the stated SNR definition and verifies achieved SNR from `alpha*s` and the same local segment. Ground truth records the exact one-based insertion sample.

For each noise-only trial, retain its maximum score. An empirical upper quantile of these maxima sets the fixed threshold for the selected receiver duration, template, preprocessing, and score mode. This calibration is only as representative as its noise-only recordings; estimated Pfa should be reported with sample size. ROC curves require independent noise and signal-present score samples.
