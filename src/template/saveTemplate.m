function saveTemplate(fileName,template,metadata)
%SAVETEMPLATE Save the waveform and provenance metadata without amplitude loss.
if nargin<3||~isstruct(metadata), error('saveTemplate:Metadata','Metadata struct is required.'); end
if ~isfolder(fileparts(fileName)), mkdir(fileparts(fileName)); end
s=template(:); save(fileName,'s','metadata','-v7');
end
