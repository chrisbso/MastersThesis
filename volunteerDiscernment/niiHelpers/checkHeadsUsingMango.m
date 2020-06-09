%% Check the .nii-files you've gathered with Mango (.nii-reader),
%   and check (by eye) if the images are indeed the same head.
function checkHeadsUsingMango(files,headIndices)
for i = 1:length(headIndices)
    idx = headIndices{i};
    if length(idx) >= 10
        error('You are gonna open 10 frikkin windows of Mango at the same time!')
    end
    fprintf('\nOpening the images...\n')
    for j = 1:length(idx)
        winopen(files{idx(j)})
        pause(0.5)
    end
    
    
    sstr = ['\nHead nmbr ' num2str(i) '/' num2str(length(headIndices)) '. Press Enter to continue. Input "ESC" to escape the program.\n'];
    uin = input(sstr,'s');
    if strcmp(uin,'ESC')
        break
    end
    !taskkill -f -im javaw.exe
end
end