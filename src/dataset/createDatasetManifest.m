function manifest = createDatasetManifest(folder,source,licenseText,outFile)
%CREATEDATASETMANIFEST Write manifest rows from file metadata (no inferred labels).
if nargin<2, source='user supplied'; end
if nargin<3, licenseText='not provided'; end
if ~iscell(folder), folder={folder}; end
if isempty(folder), error('createDatasetManifest:Folder','Provide one or more dataset folders.'); end
items=repmat(struct('file','','sampleRate',NaN,'channels',NaN,'samples',NaN,'durationSeconds',NaN),0,1);
for k=1:numel(folder), items=[items;inspectDataset(folder{k})]; end %#ok<AGROW>
if nargin<4, outFile=fullfile(folder{1},'..','manifests','dataset_manifest.csv'); end
manifest=table(string({items.file})',repmat(string(source),numel(items),1),repmat(string(licenseText),numel(items),1), ...
 [items.sampleRate]',[items.channels]',[items.samples]',[items.durationSeconds]', ...
 'VariableNames',{'file','source','license','sampleRateHz','channels','samples','durationSeconds'});
if ~isfolder(fileparts(outFile)), mkdir(fileparts(outFile)); end
writetable(manifest,outFile);
end
