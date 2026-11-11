function app = main()
%MAIN Launch the signal detection dashboard.
root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(root,'src')));
addpath(fullfile(root,'app'));
app = SignalDetectionApp();
end
