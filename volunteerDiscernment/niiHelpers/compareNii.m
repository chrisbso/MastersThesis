%% Compare one image (.nii) to a set of others, and return their correlation coefficient
%   For this to work properly, the images need to be aligned.
function rVec = compareNii(files,refInd,binaryMask)
refImg = niftiread(files{refInd});
refImg(isnan(refImg)) = 0;
rVec = ones(length(files),1);
for i = 1:length(files)
    compareImg = niftiread(files{i});
    compareImg(isnan(compareImg)) = 0;
    if nargin < 3
        rVec(i) = corr3(refImg,compareImg);
    elseif nargin > 2
        rVec(i) = corr3(double(uint16(refImg)),double(uint16(compareImg)),binaryMask);
        %rVec(i) = mutInf(uint16(refImg),uint16(compareImg));
    end
end
end