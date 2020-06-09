%% Finds the head-head pairing in the "files"-array, based on the Pearson Correlation Coefficient
%   P.S. Use rPercentile = 0.95, works like a charm for the dataset you have now :D

%   If you want to use a binary mask to remove signal voids outside heads, enter a maskThreshold,
%   however, note that this must be very low (e.g. 0.01) to do remove a lot
%   of void, and not screw up the correlation cross checks. Too high gives
%   an error in the cross check if you don't choose your rPercentile
%   correctly. Some trial and error here, or you can comment out the error
%   message if you'd like, see line 25 in "retrieveHeadPairIndices.m".

function headIndices = headDiscernment(files,rPercentile,maskThreshold,typee,boolPlot)
    if isempty(files)
        files = load('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\b0b1tools\helpers\Soerensen\niiCode\niiHelpers\filenamesForTest.mat','justHeadFiles');
        files = files.justHeadFiles;
    end
    if ~isequal(maskThreshold,[])
        binaryORMask = generateExplicitBinaryORMask(files,maskThreshold);
        rMat = retrieveComparisonsNii(files,binaryORMask);
    else
        rMat = retrieveComparisonsNii(files); %retrieve all comparisons
    end
    for i = 1:length(rMat)
        rMat(i,:) = rMat(i,:)/rMat(i,i);
    end
    headIndices = retrieveHeadPairIndices(rMat,rPercentile); %construct the cell containing indicies relative to "files".
    if boolPlot
        plotAllComparison(rMat,rPercentile,files,headIndices,typee); %plot all the comparisons made
        %plotAllComparison(rMat,rPercentile,files);
    end
    %checkHeadsUsingMango(files,headIndices);
    %checkLonelyHeadsUsingMango(files,headIndices)
end