function plotSpectrogram(ax,x,fs)
%PLOTSPECTROGRAM Toolbox-independent short-time power spectrum view.
x=x(:); if isempty(x)||fs<=0, error('plotSpectrogram:Input','Signal must be nonempty and Fs positive.'); end
L=min(256,max(2,numel(x))); hop=max(1,floor(L/2)); nfft=2^nextpow2(L);
w=0.5-0.5*cos(2*pi*(0:L-1)'/(L-1)); starts=1:hop:max(1,numel(x)-L+1);
if starts(end)+L-1<numel(x), starts(end+1)=numel(x)-L+1; end
S=zeros(nfft,numel(starts));
for k=1:numel(starts), frame=zeros(L,1); idx=starts(k):min(numel(x),starts(k)+L-1); frame(1:numel(idx))=x(idx); S(:,k)=fft(frame.*w,nfft); end
if isreal(x), bins=1:floor(nfft/2)+1; f=(bins-1)'*fs/nfft; S=S(bins,:); else, S=fftshift(S,1); f=(-nfft/2:nfft/2-1)'*fs/nfft; end
imagesc(ax,(starts+(L-1)/2-1)/fs,f,10*log10(abs(S).^2+eps)); axis(ax,'xy');
xlabel(ax,'Time (s)'); ylabel(ax,'Frequency (Hz)'); title(ax,'Short-time power spectrum'); colorbar(ax);
end
