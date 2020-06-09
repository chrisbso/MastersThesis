for i = 2:length(justHeadFiles)
    fprintf(['\n Iteration ' num2str(i) ' of ' num2str(length(justHeadFiles))]);
    sepp = strfind(justHeadFiles{i},'\');
    source = justHeadFiles{i};
    copyfile(source(1:sepp(end-1)),['D:\NN_training_data\heads\head' num2str(i)]);
end