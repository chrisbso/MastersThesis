%% Calculate a joint (OR) explicit binary mask for a given threshold (0-1) across all images,
%   to remove voxels which are NOT in the ROI and can erroneously contribute to
%   correlation.
function binaryORMask = generateExplicitBinaryORMask(files,maskThreshold)
    V = niftiread(files{1});
    binaryORMask = false(size(V));
    for i = 1:length(files)
       V = niftiread(files{i});
       V(isnan(V)) = 0;
       binaryORMask = (binaryORMask | (V > max(V(:))*maskThreshold));
    end
end