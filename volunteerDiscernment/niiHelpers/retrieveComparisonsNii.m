%% Retrieve all cross-comparisons of files, and return them in a m-x,...
% ... where each row is the comparison of image corresponding to row index to the rest
function rMat = retrieveComparisonsNii(files,binaryMask)
rMat = zeros(length(files));
for i = 1:length(files)
    if nargin < 2
        rMat(i,:) = compareNii(files,i);
    elseif nargin > 1
        rMat(i,:) = compareNii(files,i,binaryMask);
    end
end

end