function files = retrieveFileNames(parentDirPath,filename,mapType)
if strcmp(parentDirPath(end),'\') || strcmp(parentDirPath(end),'/')
   parentDirPath = parentDirPath(1:end-1); %%remove the slash in case. 
end

if strcmp(mapType,'b0')
    ffiles = dir([parentDirPath '\**\*fieldmap*\' filename]);
elseif strcmp(mapType,'b1')
    ffiles = dir([parentDirPath '\**\*dream*\' filename]);
else
    error('Rubbish map type, use "b0" or b1"!')
end

files = cell(length(ffiles),1);
for i = 1:length(ffiles)
   files{i,1} = [ffiles(i).folder '\' ffiles(i).name];
end

end