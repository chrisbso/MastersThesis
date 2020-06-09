%% Take cell array "nnData" and "idxsList", and split them into training, validation and test libraries
% Specify which "headXX" you want to include in the respective libraries
% with the three latter inputs to this func (as row vectors!)
function [XTrain,YTrain,XVal,YVal,XTest,YTest] = splitRFdata(nnData,idxsList,trainIdxs,valIdxs,testIdxs,numExPer)
nonuniqueIdxs = union(union(trainIdxs,valIdxs),testIdxs);
assert(~isempty(nonuniqueIdxs),'Make sure there is no overlap in the indices')

if nargin < 2
    error('Please specify the data set you want to split and its index list.')
end

numelOut = 15; 
numelIn = 4;

if isempty(numExPer)
    numExPer = size(nnData{1},1);
elseif numExPer > size(nnData{1},1)
    fprintf(['Too many examples per head (setting to max of ' num2str(size(nnData{1},1)) ' examples\n)']);
    numExPer = size(nnData{1},1);
end

trainList = repmat("head",length(trainIdxs),1);
trainList = strcat(trainList, string(trainIdxs'));
XTrain = zeros(length(trainIdxs)*numExPer,numelIn);
YTrain = zeros(length(trainIdxs)*numExPer,numelOut);

valList = repmat("head",length(valIdxs),1);
if ~isempty(valIdxs)
    valList = strcat(valList, string(valIdxs'));
end
XVal = zeros(length(valIdxs)*numExPer,numelIn);
YVal = zeros(length(valIdxs)*numExPer,numelOut);

testList = repmat("head",length(testIdxs),1);
if ~isempty(testIdxs)
    testList = strcat(testList, string(testIdxs'));
end
XTest = zeros(length(testIdxs)*numExPer,numelIn);
YTest = zeros(length(testIdxs)*numExPer,numelOut);


kTrain = 0; kVal = 0; kTest = 0;
for ii = 1:length(idxsList)
    X = cell2mat(nnData{ii}(:,1:2));
    
    % if the coeffs are along the rows instead of the columns, swap them
    % when putting into a set.
    Ycheck = nnData{ii}(1,3);
    Ycheck = Ycheck{1};
    if size(Ycheck,1) ~= 1
        Y = cell2mat([swapDim(nnData{ii}(:,3)),swapDim(nnData{ii}(:,4))]);
    else
        Y = cell2mat(nnData{ii}(:,3:4));
    end
    
    if any(strcmp(trainList,idxsList{ii}))
        XTrain((1+kTrain*numExPer):(kTrain+1)*numExPer,:) = X(1:numExPer,:);
        YTrain((1+kTrain*numExPer):(kTrain+1)*numExPer,:) = Y(1:numExPer,:);
        kTrain = kTrain + 1;
        
    elseif any(strcmp(valList,idxsList{ii}))
        XVal((1+kVal*numExPer):(kVal+1)*numExPer,:) = X(1:numExPer,:);
        YVal((1+kVal*numExPer):(kVal+1)*numExPer,:) = Y(1:numExPer,:);
        kVal = kVal + 1;

    elseif any(strcmp(testList,idxsList{ii}))
        XTest((1+kTest*numExPer):(kTest+1)*numExPer,:) = X(1:numExPer,:);
        YTest((1+kTest*numExPer):(kTest+1)*numExPer,:) = Y(1:numExPer,:);
        kTest = kTest + 1;
    else
        %error('Head not found!');
    end
   
   
end 
    XTrain  = reshape(XTrain',1,numelIn,1,[]);
    XVal    = reshape(XVal',1,numelIn,1,[]);
    XTest   = reshape(XTest',1,numelIn,1,[]);

end

function swapped = swapDim(cellArr)
swapped = cellArr;
    for i = 1:length(cellArr)
        swapped(i) = {cellArr{i}'};
    end
end