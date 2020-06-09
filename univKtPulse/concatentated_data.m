function [cat_b1p,cat_MTarg,cat_b0Interp,cat_X,cat_Y,cat_Z,cat_smallerVOIs] = concatentated_data(parentDir,initHeight,initWidth,typee,files)

cat_b1p = zeros(initHeight,initWidth,0,8);
cat_MTarg = zeros(initHeight,initWidth,0);
cat_b0Interp = zeros(initHeight,initWidth,0);
cat_X = zeros(initHeight,initWidth,0); % X Y Z
cat_Y = zeros(initHeight,initWidth,0);
cat_Z = zeros(initHeight,initWidth,0);
cat_smallerVOIs = zeros(initHeight,initWidth,0,6);

%No files specified, just do the concat on all maps except a few (minus "k");
if nargin < 5
    if ~isunix
        listing = dir([parentDir '\head*\*_dt_dream*\reconstructed.mat']);
    else
        listing = dir([parentDir '/head*/*_dt_dream*/reconstructed.mat']);
    end
    
    k = 2;
    for i = 1:length(listing)-k
        if strcmp(typee,'ktshim')
            s = load([listing(i).folder slsh listing(i).name],'b1p_kt','MTarg_kt','b0Interp','meshGridCoords','smallerVOIs');
            cat_b1p     = cat(3,cat_b1p,s.b1p_kt);
            cat_MTarg   = cat(3,cat_MTarg,s.MTarg_kt);
        elseif strcmp(typee,'acshim')
            s = load([listing(i).folder slsh listing(i).name],'b1p','MTarg','b0Interp','meshGridCoords','smallerVOIs');
            cat_b1p     = cat(3,cat_b1p,s.b1p);
            cat_MTarg   = cat(3,cat_MTarg,s.MTarg);
        else
            error('Please input a proper type!');
        end
        cat_b0Interp = cat(3,cat_b0Interp,s.b0Interp);
        cat_X       = cat(3,cat_X,s.meshGridCoords{1});
        cat_Y       = cat(3,cat_Y,s.meshGridCoords{2});
        cat_Z       = cat(3,cat_Z,s.meshGridCoords{3});
        cat_smallerVOIs = cat(3,cat_smallerVOIs,s.smallerVOIs);
    end
    
    for j = k:-1:1
        disp(listing(end-(j-1)).folder)
        fprintf('\n');
    end
else
    %You have specified which reconstructed.mat-files you want to include.
    for i = 1:length(files)
        if strcmp(typee,'ktshim')
            s = load(files{i},'b1p_kt','MTarg_kt','b0Interp','meshGridCoords','smallerVOIs');
            cat_b1p     = cat(3,cat_b1p,s.b1p_kt);
            cat_MTarg   = cat(3,cat_MTarg,s.MTarg_kt);
        elseif strcmp(typee,'acshim')
            s = load(files{i},'b1p','MTarg','b0Interp','meshGridCoords','smallerVOIs');
            cat_b1p     = cat(3,cat_b1p,s.b1p);
            cat_MTarg   = cat(3,cat_MTarg,s.MTarg);
        else
            error('Please input a proper type!');
        end
        cat_b0Interp = cat(3,cat_b0Interp,s.b0Interp);
        cat_X       = cat(3,cat_X,s.meshGridCoords{1});
        cat_Y       = cat(3,cat_Y,s.meshGridCoords{2});
        cat_Z       = cat(3,cat_Z,s.meshGridCoords{3});
        cat_smallerVOIs = cat(3,cat_smallerVOIs,s.smallerVOIs);
    end
end
end