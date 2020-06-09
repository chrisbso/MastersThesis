%% Get the struct contatining the directories
function dirStruct = getDirStruct(files)
dirStruct = dir(files{1});
for i = 2:length(files)
    dirStruct = [dirStruct,dir(files{i})];
end
end