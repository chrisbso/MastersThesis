%% Compare the different shimming methods (Tailored, UP, NET-JOUP, NET-UP)

%% Set up all the networks
trainIdxs = [4, 9, 10, 12,14];
%dat_NJO = load('D:\NN_training_data\generatedRFdata_20203161527_nIter3000.mat','nnData','idxs');

%% load training data
    %% laptop version
%dat_NJO = load('D:\NN_training_data\generatedRFdata_202055197_nIter3000.mat','nnData','idxs');
%dat_JO = load('D:\NN_training_data\generatedRFdata_jointOpt2020551356_nIter16000.mat','XTrain','YTrain');

    %% spindoc version
dat_NJO = load('/home/chrisbso/Dokumenter/generatedData/generatedRFdata_202055197_nIter3000.mat','nnData','idxs');
dat_JO = load('/home/chrisbso/Dokumenter/generatedData/generatedRFdata_jointOpt2020551356_nIter16000.mat','X_joint','Y_joint');

firstLayerSize     = [1024];
secondLayerSize    = [1024];
thirdLayerSize     = [1024];
 nTrain = 14000;


%Validation data. Point is, you want to verify the trained PTx-coeffs over the
%training volunteers, it doesn't make sense to verify anything else.
%% load validation data
    %% laptop version
        %dat_NJO_val = load('D:\NN_training_data\generatedRFdata_20204211559_nIter200_val.mat');

    %% spindoc version
        dat_NJO_val = load('/home/chrisbso/Dokumenter/generatedData/generatedRFdata_2020561551_nIter200_val.mat','nnData','idxs');

NVal = 1000;
[XVal_NJO,YVal_NJO,~,~,~,~] = splitRFdata(dat_NJO_val.nnData,dat_NJO_val.idxs,trainIdxs,[],[],floor(NVal/length(trainIdxs)));

%Same here. Assumes you don't use the last NVal training examples
%during training (s.t. those examples aren't actually trained on!) 
XVal_JO = dat_JO.X_joint(:,:,:,nTrain(end)+1:(nTrain(end)+NVal));
YVal_JO = dat_JO.Y_joint(nTrain(end)+1:(nTrain(end)+NVal),:);
[X_NJO,Y_NJO,~,~,~,~] = splitRFdata(dat_NJO.nnData,dat_NJO.idxs,trainIdxs,[],[],floor(nTrain/length(trainIdxs)));

[layers,options] = generateNetworkArchitecture(firstLayerSize,secondLayerSize,thirdLayerSize,XVal_JO,YVal_JO);
RFUPNet  = trainNetwork(dat_JO.X_joint(:,:,:,1:nTrain),dat_JO.Y_joint(1:nTrain,:),layers,options);
[layers,options] = generateNetworkArchitecture(firstLayerSize,secondLayerSize,thirdLayerSize,XVal_NJO,YVal_NJO);
tailoredNet = trainNetwork(X_NJO,Y_NJO,layers,options);




clearvars -except tailoredNet RFUPNet trainIdxs nTrain nVal options
