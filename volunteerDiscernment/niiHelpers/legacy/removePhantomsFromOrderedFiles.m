k = 1;
for i = 1:length(outt)
    aa = outt{i};
    winopen(orderedFiles{aa(1)});
    strr = input('Is this a head?','s');
    if strcmp(strr,'1')
        for j = 1:length(aa)
            justHeadFiles{k} = orderedFiles{aa(j)};
            k = k + 1;
        end
    end
    !taskkill -f -im javaw.exe
end