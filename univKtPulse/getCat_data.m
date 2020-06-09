%% Help function to get the concatentated data for UP-optimizations
function [cat_b1p,cat_MTarg,cat_b0Interp,cat_X,cat_Y,cat_Z,cat_smallerVOIs] = getCat_data(typee,files)
parentDir = 'D:\NN_training_data\heads';
if strcmp(typee,'ktshim')
    if nargin > 1
        [cat_b1p,cat_MTarg,cat_b0Interp,cat_X,cat_Y,cat_Z,cat_smallerVOIs] = concatentated_data(parentDir,56,64,typee,files);
    else
        [cat_b1p,cat_MTarg,cat_b0Interp,cat_X,cat_Y,cat_Z,cat_smallerVOIs] = concatentated_data(parentDir,56,64,typee);  
    end
elseif strcmp(typee,'acshim')
    if nargin > 1
        [cat_b1p,cat_MTarg,cat_b0Interp,cat_X,cat_Y,cat_Z,cat_smallerVOIs] = concatentated_data(parentDir,56,64,typee,files);
    else
        [cat_b1p,cat_MTarg,cat_b0Interp,cat_X,cat_Y,cat_Z,cat_smallerVOIs] = concatentated_data(parentDir,56,64,typee);  
    end

end
end

