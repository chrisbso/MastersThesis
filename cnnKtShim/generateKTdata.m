%% Generate the data needed to train the CNN
function [XTrain,YTrain,XVal,YVal,XTest,YTest] = generateKTdata(ktp_opts,trainIdxs,valIdxs,testIdxs,parentDir,saveDir,saveName)

if nargin == 0
ktp_opts = [];
saveDir = [];
saveName = [];
trainIdxs = [1:13];
valIdxs = [14:15];
testIdxs = [16:17]; 
%parentDir = 'C:\Users\omgwt\Documents\ChristofferMasterData\heads';
parentDir = 'E:\MRI_DL\heads\heads';
end

nonuniqueIdxs = union(union(trainIdxs,valIdxs),testIdxs);
assert(~isempty(nonuniqueIdxs),'Make sure there is no overlap in the indices')


if isempty(parentDir)
    parentDir = 'D:\NN_training_data\heads';
end

% if isempty(saveDir)
%     saveDir = 'D:\NN_training_data';
% end
% 
% if isempty(saveName) 
%     c = clock; % get the time and date
%     c = num2str(c(1:end-1)); %remove seconds
%     saveName = ['generatedRFdata_jointOpt' c(~isspace(c)) '_nIter' num2str(nIter) '.mat'];
% end

%find out what folder you're running this in, and load the proper workspace
%variables;
funcFold = mfilename('fullpath');
[~,funcFold] = strtok(fliplr(funcFold),slsh);
funcFold = fliplr(funcFold);

tmpp = load([funcFold 'ktp_ws.mat'],'opts','vars');
opts = tmpp.opts;
vars = tmpp.vars;
clear tmpp

vars.verbose = 0;
if isfield(ktp_opts,'kpnts')
   vars.kpnts = ktp_opts.kpnts; 
end

if isfield(ktp_opts,'kspac')
   vars.kspac = ktp_opts.kspac; 
end

if isfield(ktp_opts,'targetFA')
   vars.targetFA = ktp_opts.targetFA; 
end

if isfield(ktp_opts,'TR')
   vars.TR = ktp_opts.TR; 
end
clear ktp_opts;

outputSize = 2*vars.kpnts*8-1;  %outputs for training (real and imag. parts of coeffs)
inputSize  = [56,64,21]; %input feature map
nCh = 1; % #channels (maybe just stick to abs(sum(b1p,4)), so nCh = 1?)

XTrain = zeros([inputSize nCh length(trainIdxs)]);
YTrain = zeros(length(trainIdxs),outputSize);
trainFiles = getHeadFilesCellArr(trainIdxs,parentDir);


XVal = zeros([inputSize nCh length(valIdxs)]);
YVal = zeros(length(valIdxs),outputSize);
valFiles = getHeadFilesCellArr(valIdxs,parentDir);


XTest = zeros([inputSize nCh length(testIdxs)]);
YTest = zeros(length(testIdxs),outputSize);
testFiles = getHeadFilesCellArr(testIdxs,parentDir);
totalIter = length(trainFiles)+length(testFiles)+length(testFiles);
h = waitbar(0,'Starting data generation for ktshim');
k = 0;
for ii = 1:length(trainFiles)
       perc = floor(100*(k)/totalIter);
       waitbar(perc/100,h,sprintf('Calculating (train): scan %d/%d, %d%% done...',k+1,totalIter,perc));
       
       cd(trainFiles{ii});
       %set up MIDs
       MIDs = getMIDsForKTshim(trainFiles{ii});
       clear MIDsListing
       
       [coeffs,~,res] = ktshim(MIDs,opts,vars);
       
       coeffs = coeffs*exp(-1i*angle(coeffs(1,1))); %phase shift to remove first coeff's imag part
       coeffsRe = real(coeffs(:))'; %get the real parts (need all)
       coeffsIm = imag(coeffs(:))'; %get the imag parts (need all-1)
        
       XTrain(:,:,:,1,ii) = abs(adjustB1pMapForTraining(sum(res.b1pTpV,4).*res.M,21));
       YTrain(ii,:) = [coeffsRe coeffsIm(2:end)];
       k = k + 1;
       
end

for ii = 1:length(valFiles)
       perc = floor(100*(k)/totalIter);
       waitbar(perc/100,h,sprintf('Calculating (validate): scan %d/%d, %d%% done...',k+1,totalIter,perc));
       
       cd(valFiles{ii});
       %set up MIDs
       MIDs = getMIDsForKTshim(valFiles{ii});
       clear MIDsListing
       
       [coeffs,~,res] = ktshim(MIDs,opts,vars);
       
       coeffs = coeffs*exp(-1i*angle(coeffs(1,1))); %phase shift to remove first coeff's imag part
       coeffsRe = real(coeffs(:))'; %get the real parts (need all)
       coeffsIm = imag(coeffs(:))'; %get the imag parts (need all-1)
        
       XVal(:,:,:,1,ii) = abs(adjustB1pMapForTraining(sum(res.b1pTpV,4).*res.M,21));
       YVal(ii,:) = [coeffsRe coeffsIm(2:end)];
       k = k + 1;
       
end

for ii = 1:length(testFiles)
       perc = floor(100*(k)/totalIter);
       waitbar(perc/100,h,sprintf('Calculating (test): scan %d/%d, %d%% done...',k+1,totalIter,perc));
       
       cd(testFiles{ii});
       %set up MIDs
       MIDs = getMIDsForKTshim(testFiles{ii});
       clear MIDsListing
       
       [coeffs,~,res] = ktshim(MIDs,opts,vars);
       
       coeffs = coeffs*exp(-1i*angle(coeffs(1,1))); %phase shift to remove first coeff's imag part
       coeffsRe = real(coeffs(:))'; %get the real parts (need all)
       coeffsIm = imag(coeffs(:))'; %get the imag parts (need all-1)
        
       XTest(:,:,:,1,ii) = abs(adjustB1pMapForTraining(sum(res.b1pTpV,4).*res.M,21));
       YTest(ii,:) = [coeffsRe coeffsIm(2:end)];
       k = k + 1;
       
end
close(h);
end