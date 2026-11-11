function downloadDataset()
%DOWNLOADDATASET Download and extract Speech Commands v0.02 archives.
root=fileparts(fileparts(mfilename('fullpath')));
rawRoot=fullfile(root,'data','raw');
trainArchive=fullfile(rawRoot,'speech_commands_v0.02.tar.gz');
testArchive=fullfile(rawRoot,'speech_commands_test_set_v0.02.tar.gz');
trainFolder=fullfile(rawRoot,'speech_commands_v0.02');
testFolder=fullfile(rawRoot,'speech_commands_test_set_v0.02');
addpath(genpath(fullfile(root,'src')));
if ~isfolder(rawRoot), mkdir(rawRoot); end

% Google Cloud Storage is the secure mirror used by TensorFlow's own examples.
% Keep normal TLS certificate and host-name verification enabled.
baseNames={'speech_commands_v0.02.tar.gz','speech_commands_test_set_v0.02.tar.gz'};
urls=cell(2,2);
for k=1:2
    urls{k,1}=['https://storage.googleapis.com/download.tensorflow.org/data/' baseNames{k}];
    urls{k,2}=['https://download.tensorflow.org/data/' baseNames{k}];
end

fprintf('Preparing Speech Commands v0.02 training (>2 GB) and official test archives.\n');
if ~hasArchive(trainFolder), ensureExtracted(trainArchive,trainFolder,urls(1,:)); end
if ~hasArchive(testFolder), ensureExtracted(testArchive,testFolder,urls(2,:)); end
createDatasetManifest({trainFolder,testFolder},'Google Speech Commands v0.02', ...
    'not verified here; consult official release terms', ...
    fullfile(root,'data','manifests','speech_commands_manifest.csv'));
fprintf('Dataset WAV files and manifest are ready under %s\n',rawRoot);
end

function ensureExtracted(archivePath,destination,urls)
if ~isfile(archivePath)
    downloadSecurely(archivePath,urls);
end
stage=tempname(fileparts(destination)); mkdir(stage);
try
    untar(archivePath,stage);
    if ~hasArchive(stage)
        error('downloadDataset:IncompleteArchive','Archive extraction produced too few WAV files to be a complete split.');
    end
catch firstError
    % Keep any old archive untouched until a complete secure mirror download
    % succeeds, then retry extraction from the replacement.
    if isfolder(stage), rmdir(stage,'s'); end
    warning('downloadDataset:Retry','Archive extraction failed (%s). Retrying from the secure mirror.',firstError.message);
    downloadSecurely(archivePath,urls);
    stage=tempname(fileparts(destination)); mkdir(stage);
    try
        untar(archivePath,stage);
        if ~hasArchive(stage)
            error('downloadDataset:IncompleteArchive','Archive extraction produced too few WAV files to be a complete split.');
        end
    catch retryError
        if isfolder(stage), rmdir(stage,'s'); end
        error('downloadDataset:Extract','Could not extract %s after retry: %s',archivePath,retryError.message);
    end
end
if isfolder(destination)
    % Preserve any existing partial destination and merge staged content.
    copyfile(fullfile(stage,'*'),destination,'f');
    rmdir(stage,'s');
else
    [ok,msg]=movefile(stage,destination);
    if ~ok
        if isfolder(stage), rmdir(stage,'s'); end
        error('downloadDataset:Move','Could not install extracted dataset: %s',msg);
    end
end
end

function downloadSecurely(destination,urls)
attemptErrors=cell(size(urls));
for k=1:numel(urls)
    tempPath=[tempname(fileparts(destination)) '.download'];
    try
        websave(tempPath,urls{k});
        info=dir(tempPath);
        if isempty(info)||info.bytes==0
            error('downloadDataset:EmptyDownload','The server returned an empty file.');
        end
        [ok,msg]=movefile(tempPath,destination,'f');
        if ~ok, error('downloadDataset:Save','Could not move completed archive into place: %s',msg); end
        return
    catch e
        attemptErrors{k}=sprintf('%s -> %s',urls{k},e.message);
        if isfile(tempPath), delete(tempPath); end
    end
end
error('downloadDataset:Transfer', ...
    'All secure download hosts failed. TLS verification was not disabled. Check system certificates/proxy settings or download the archive manually from an official URL. Attempts: %s', ...
    strjoin(attemptErrors,newline));
end

function tf=hasArchive(folder)
if ~isfolder(folder), tf=false; return; end
tf=numel(dir(fullfile(folder,'**','*.wav')))>=1000;
end
