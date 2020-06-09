%% Extract the set folder numbers (NEEDS A SPECIFIC STRUCTURE IN FOLDERS, SEE BELOW)
%   All files being read are currently in hierarcy
%   "sets\setN\meas_MIDXX_*\*.nii".
%   This folder extracts said "N" for all files.
function setNumber = extractSetNumberFromFiles(files)
setNumber = zeros(length(files),1);
nMaxSets = numel(dir([files{1} '\..\..\..']))-2;
    for i = 1:length(files)
        for j = 1:nMaxSets
            if contains(files{i},['set' num2str(j) '\'])
                setNumber(i) = j;
            end
        end
    end
end