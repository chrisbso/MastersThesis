%% Train the CNN with the parameters specified in the code.
function net = trainCNNforKTshim(XTrain,YTrain,XVal,YVal)
imageSize = [56 64 21 1];
layers = [
    image3dInputLayer(imageSize,'Normalization','rescale-symmetric')
    convolution3dLayer(4,3)
    reluLayer
    
    averagePooling3dLayer([2 2 2],'Stride',2)
    reluLayer
    
    maxPooling3dLayer([2 2 2],'Stride',2)
    reluLayer
    
    
    convolution3dLayer(2,3)
    reluLayer
    
    
    fullyConnectedLayer(size(YTrain,2)) 
    reluLayer
   

    fullyConnectedLayer(size(YTrain,2))
    
    regressionLayer];

% layers = [
%     image3dInputLayer([imageSize],'Normalization','rescale-symmetric')
%     convolution3dLayer(3,8,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     averagePooling3dLayer(2,'Stride',2)
% 
%     convolution3dLayer(3,16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     averagePooling3dLayer(2,'Stride',2)
%   
%     convolution3dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     convolution3dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     dropoutLayer(0.2)
%     fullyConnectedLayer(size(YTrain,2))
%     reluLayer
%     
%     fullyConnectedLayer(size(YTrain,2))
%     reluLayer
%     
%     regressionLayer];

miniBatchSize  = 15;
validationFrequency = 1;
options = trainingOptions('adam', ...
    'InitialLearnRate',3e-3, ...
    'SquaredGradientDecayFactor',0.99, ...
    'MaxEpochs',50, ...,
    'MiniBatchSize',miniBatchSize, ...
    'ValidationData',{XVal,YVal}, ...
    'ValidationFrequency',validationFrequency, ...
    'ValidationPatience',5, ....
    'Plots','training-progress', ...
    'Verbose',false);
% options = trainingOptions('sgdm', ...
%     'MiniBatchSize',miniBatchSize, ...
%     'MaxEpochs',150, ...
%     'InitialLearnRate',0.8^2*1e-2, ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropFactor',0.8, ...
%     'LearnRateDropPeriod',25, ...
%     'Shuffle','every-epoch', ...
%     'ValidationData',{XVal,YVal}, ...
%     'ValidationFrequency',validationFrequency, ...
%     'Plots','training-progress', ...
%     'Verbose',false);

net = trainNetwork(XTrain,YTrain,layers,options);

end