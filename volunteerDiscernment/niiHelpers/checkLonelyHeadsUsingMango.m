%% Go through all heads without a match, and compare them by eye.

function checkLonelyHeadsUsingMango(files,headIndices)
for i = 1:length(headIndices)
    if length(headIndices{i}) == 1
        winopen(files{headIndices{i}});
        pause(0.5)
    end
end

    sstr = '\nPress Enter to continue.\n';
    input(sstr,'s');
    !taskkill -f -im javaw.exe
end