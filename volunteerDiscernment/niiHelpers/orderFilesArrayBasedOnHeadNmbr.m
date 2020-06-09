function ordered = orderFilesArrayBasedOnHeadNmbr(files)
    ordered = cell(size(files));
    for i = 1:length(files)
        for j = 1:length(files)
            if contains(files{j},['head' num2str(i) '\'])
                ordered(i) = files(j);
            end
        end
        if isempty(ordered{i})
            error('Something went wrong, an element went through empty =(')
        end
    end
end