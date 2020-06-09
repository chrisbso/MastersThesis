%% Generate the training data for Tailored-Net
function varargout = generateMaskTrainingForScan(MIDs,opts,vars,FOV,fullCoords)

%choose a random voxel for the target within the ROI instead of the full
%3D matrix
% [h,w,d] = ind2sub(size(brainMask.Mspm),find(brainMask.Mspm));
% rIdx = randi(length(h)); %random XYZ-indices
% vars.GaussMCnt = [h(rIdx) w(rIdx) d(rIdx)]; %set Gauss Mask center
% vars.GaussMask = repmat(0.015 + 0.035*rand(),1,3); %random (spherical) drop-off

FOV(3)  = 210; % a small cheat, the max FOV of all the data 
FOV     = 0.72*FOV/1e3; % in meters

rCoord = [-FOV(1)/2+rand()*FOV(1), -FOV(2)/2+rand()*FOV(2), -FOV(3)/2+rand()*FOV(3)];
%get vox coords of center of blob
[~,posn(1)] = min(abs(fullCoords{1}-rCoord(1)));
[~,posn(2)] = min(abs(fullCoords{2}-rCoord(2)));
[~,posn(3)] = min(abs(fullCoords{3}-rCoord(3)));

vars.GaussMCnt = posn;
vars.GaussMask = repmat((0.01 + 0.03*rand()),1,3); %random (spherical) drop-off

[coeffs,~,~] = acshim(MIDs,opts,vars); %compute coeffs
    

%coords = [fullCoords{1}(vars.GaussMCnt(1)) fullCoords{2}(vars.GaussMCnt(2)) fullCoords{3}(vars.GaussMCnt(3))];
dropOff = vars.GaussMask(1); %assuming spherical drop-off
coeffsReal = real(coeffs);
coeffsIm = imag(coeffs(2:end));

varargout{1} = rCoord;
varargout{2} = dropOff;
varargout{3} = coeffsReal;
varargout{4} = coeffsIm;
%varargout{5} = res.MTarg;
end

