%% Compare the different shimming methods (Tailored, UP, NET-JOUP, NET-UP)

%% Set up all the networks
trainIdxs = [4, 9, 10, 12,14];
%dat_NJO = load('D:\NN_training_data\generatedRFdata_20203161527_nIter3000.mat','nnData','idxs');
dat_NJO = load('D:\NN_training_data\generatedRFdata_20204141549_nIter3000.mat','nnData','idxs');
dat_JO = load('D:\NN_training_data\generatedRFdata_jointOpt2020422116_nIter16000.mat','XTrain','YTrain');

% firstLayerSizes     = [64,128,256];
% secondLayerSizes    = [32,64,128];
% thirdLayerSizes     = [16,32,64];
% nTrain = [125,250,500,1000,1500,2000,2500,3000];

firstLayerSizes     = [2*1024];
secondLayerSizes    = [2*512];
thirdLayerSizes     = [2*256];
 nTrain = 14000;

LayerSizesLen = length(firstLayerSizes);
nTrainLen = length(nTrain);

nets_JO     = cell(nTrainLen,LayerSizesLen);
nets_NJO    = cell(nTrainLen,LayerSizesLen);

%Validation data. Point is, you want to verify the trained PTx-coeffs over the
%training volunteers, it doesn't make sense to verify anything else.
dat_NJO_val = load('D:\NN_training_data\generatedRFdata_20204211559_nIter200_val.mat');
NVal = 1000;
[XVal_NJO,YVal_NJO,~,~,~,~] = splitRFdata(dat_NJO_val.nnData,dat_NJO_val.idxs,trainIdxs,[],[],floor(NVal/length(trainIdxs)));


%dat_JO_val = load('D:\NN_training_data\generatedRFdata_jointOpt20204162156_nIter1000_val.mat');
%Same here. Assumes you don't use the last NVal training examples
%during training (s.t. those examples aren't actually trained on!) 
XVal_JO = dat_JO.XTrain(:,:,:,nTrain(end)+1:(nTrain(end)+NVal));
YVal_JO = dat_JO.YTrain(nTrain(end)+1:(nTrain(end)+NVal),:);

h = waitbar(0,'(PART 1) Starting network training...'); %some progress-bar
for ii =  1:nTrainLen 
    [XTrain_NJO,YTrain_NJO,~,~,~,~] = splitRFdata(dat_NJO.nnData,dat_NJO.idxs,trainIdxs,[],[],floor(nTrain(ii)/length(trainIdxs)));
    for jj = 1:LayerSizesLen
        [layers,options] = generateNetworkArchitecture(firstLayerSizes(jj),secondLayerSizes(jj),thirdLayerSizes(jj),XVal_JO,YVal_JO);
        nets_JO{ii,jj}  = trainNetwork(dat_JO.XTrain(:,:,:,1:nTrain(ii)),dat_JO.YTrain(1:nTrain(ii),:),layers,options);
        [layers,options] = generateNetworkArchitecture(firstLayerSizes(jj),secondLayerSizes(jj),thirdLayerSizes(jj),XVal_NJO,YVal_NJO);
        nets_NJO{ii,jj} = trainNetwork(XTrain_NJO,YTrain_NJO,layers,options);
        
        perc = floor(100*(jj+LayerSizesLen*(ii-1))/(nTrainLen*LayerSizesLen));
        waitbar(perc/100,h,sprintf('(PART 1) Training: Iter %d/%d, %d%% done...',jj+LayerSizesLen*(ii-1),nTrainLen*LayerSizesLen,perc));
    end
end
close(h);

clear dat_NJO XTrain_NJO YTrain_NJO layers options perc ii jj h

%% Set up the test examples and calculate NRMSE
testIdxs = [15 16 17]; %test data
testFiles = getHeadFilesCellArr(testIdxs); %get the file locations
testRecFiles = getReconstructedFilesCellArr(testIdxs);
load('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\b0b1tools\helpers\Soerensen\redoRFshim\acshimVars.mat'); %get the vars for acshim
nTest = 1000;

%[XTest,YTest_joint] = generateRFdata_jointOpt([],[],[],nTest,trainIdxs,vars); %XTest and jointly optimised coeffs
XTest = dat_JO.XTrain(:,:,:,(nTrain(end)+NVal+1):(nTrain(end)+NVal+nTest));
YTest_joint = dat_JO.YTrain((nTrain(end)+NVal+1):(nTrain(end)+NVal+nTest),:);
clear dat_JO
%YTest = YTest_joint';
%coeffs = YTest(1:8,:) -1i*[zeros(1,size(YTest,2));YTest(9:end,:)];

NRMSE_nets_JO    = zeros(nTrainLen,LayerSizesLen,length(testIdxs),nTest);
NRMSE_nets_NJO   = zeros(nTrainLen,LayerSizesLen,length(testIdxs),nTest);

opts = 'eB';
h = waitbar(0,'(PART 2) Starting average NRMSE calculations...'); %some progress-bar
for k = 1:length(testIdxs)
    load(testRecFiles{k},'aux');
    cd(testFiles{k});
    MIDsListing = dir('*_dt_dream*.dat');
       if length(MIDsListing) ~= 1
           error('Found several DREAM-files in one folder.')
       else
           MIDsName = MIDsListing(1).name;
           MIDs = extractBetween(MIDsName,'MID','_dt');
           MIDs = str2num(MIDs{1});
       end
        for n = 1:nTest
            tmpp = XTest(1,:,1,n);
            [~,posn(1)] = min(abs(aux.coords{1}-tmpp(1)));
            [~,posn(2)] = min(abs(aux.coords{2}-tmpp(2)));
            [~,posn(3)] = min(abs(aux.coords{3}-tmpp(3)));

            vars.GaussMCnt = posn;
            vars.GaussMask = repmat(tmpp(4),1,3);
            parfor ii = 1:nTrainLen
                varss = vars;
                for jj = 1:LayerSizesLen
                    varss.coeffs = predictAndConstructRFSetting(nets_JO{ii,jj},tmpp);
                    [~,fitn_JO,~] = acshim(MIDs,opts,varss);
                    NRMSE_nets_JO(ii,jj,k,n) = fitn_JO.stdFT;

                    varss.coeffs = predictAndConstructRFSetting(nets_NJO{ii,jj},tmpp);
                    [~,fitn_NJO,~] = acshim(MIDs,opts,varss);
                    NRMSE_nets_NJO(ii,jj,k,n) = fitn_NJO.stdFT;
                end
            end
        
                perc = floor(100*(n+nTest*(k-1))/(nTest*length(testIdxs)));
                waitbar(perc/100,h,sprintf('(PART 2) Calculating: Iter %d/%d, %d%% done...',n+nTest*(k-1),nTest*length(testIdxs),perc));
        
        end
end
close(h);

%clear fitn_JO fitn_NJO testFiles testRecFiles ii jj k n MIDs MIDsName MIDsListing YTest

%NRMSE_nets_JO    = NRMSE_nets_JO  / (nTest*length(testIdxs));
%NRMSE_nets_NJO   = NRMSE_nets_NJO / (nTest*length(testIdxs));

NRMSE_tail   = NRMSE_tailored(XTest,testIdxs,vars);
NRMSE_JO     = NRMSE_jointlyOptimised(XTest,YTest_joint,testIdxs,vars);
%% Save the stuff
saveDir = 'D:\NN_training_data';
%
c = clock; % get the time and date
c = num2str(c(1:end-1)); %remove seconds
saveName = ['comparedRFShimMethods_' c(~isspace(c)) '_nTest' num2str(nTest) '.mat'];
save([saveDir slsh saveName],'NRMSE_nets_JO','NRMSE_nets_NJO', 'NRMSE_tail','NRMSE_JO',...,
    'nTrain','firstLayerSizes','secondLayerSizes','thirdLayerSizes','trainIdxs');

clear XTest YTest_joint vars tmpp nTrainLen LayerSizesLen c h perc saveDir saveName



    