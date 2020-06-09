%% A help function to get the proper names for reconstructed.mat-files for head idxs in
% "heads"
function files = getReconstructedFilesCellArr(heads,parentDir)
if nargin < 2 && ~isunix()
    parentDir = 'D:\NN_training_data\heads';
end
files = cell(0);
for i = 1:length(heads)
    if isunix()
        tmp = dir([parentDir '/**/head' num2str(heads(i)) '/**/*_dt_dream_*/reconstructed.mat']);
    else
        tmp = dir([parentDir '\**\head' num2str(heads(i)) '\**\*_dt_dream_*\reconstructed.mat']);
    end
    files{i} = [tmp.folder slsh tmp.name];
end
files = files';
    
end