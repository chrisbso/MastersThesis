%% A help function to get the proper names for the head dirs for headidxs in
% "heads"
function files = getHeadFilesCellArr(heads,parentDir)
if nargin < 2 && ~isunix
    parentDir = 'D:\NN_training_data\heads';
end
files = cell(0);
for i = 1:length(heads)
    if isunix()
        tmp = dir([parentDir '/**/head' num2str(heads(i))]);
    else
        tmp = dir([parentDir '\**\head' num2str(heads(i))]);
    end
    files{i} = tmp.folder;
end
files = files';
    
end