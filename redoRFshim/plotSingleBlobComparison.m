%% Plot an example comparison
function plotSingleBlobComparison(headIdx,trainIdxs,RFUPNet,tailoredNet,parentDir)
%% Set up parent directory if not specified
if isempty(parentDir)
    parentDir = 'D:\NN_training_data\heads';
end
%% Find out what folder you're running this in, and load the proper workspace variables;
funcFold = mfilename('fullpath');
[~,funcFold] = strtok(fliplr(funcFold),slsh);
funcFold = fliplr(funcFold);

headFile = getHeadFilesCellArr(headIdx);
recFile = getReconstructedFilesCellArr(headIdx);
tmppp = load(recFile{1},'aux','Mspm','prot');
tmpp = load([funcFold 'acshimVars1.mat'],'vars');
vars = tmpp.vars;
vars.GaussMask = repmat(0.01,1,3);
vars.GaussMCnt = getComass(tmppp.prot,tmppp.aux)-[10 0 0];
vars.svsBoxSize = [20 20 20];
clear tmpp

%% Set up the b1p's for the joint optimization (done over test files)
trainFiles      = getHeadFilesCellArr(trainIdxs,parentDir);
trainRecFiles   = getReconstructedFilesCellArr(trainIdxs,parentDir);
for i = 1:length(trainRecFiles)
            tmp = load(trainRecFiles{i},'b1p_kt'); %%this "_kt"-part already done the weird phase-shifting
            if i == 1
                vars.catB1p = tmp.b1p_kt;
            else
                vars.catB1p = cat(3,vars.catB1p,tmp.b1p_kt);
            end
end
clear tmp;
testTargetCoord = ...
    [tmppp.aux.coords{1}(vars.GaussMCnt(1)),...
     tmppp.aux.coords{2}(vars.GaussMCnt(2)),...
     tmppp.aux.coords{3}(vars.GaussMCnt(3))];

for k = 1:length(trainFiles)
    trainTmp = load(trainRecFiles{k},'Mspm','aux');

    %get vox coords of center of blob
    [~,posn(1)] = min(abs(trainTmp.aux.coords{1}-testTargetCoord(1)));
    [~,posn(2)] = min(abs(trainTmp.aux.coords{2}-testTargetCoord(2)));
    [~,posn(3)] = min(abs(trainTmp.aux.coords{3}-testTargetCoord(3)));

    newMTarg = (trainTmp.Mspm).*gaussianmask(trainTmp.Mspm,trainTmp.aux,posn,vars.GaussMask);
    if k == 1
        vars.catMTarg = newMTarg;
    else
        vars.catMTarg = cat(3,vars.catMTarg,newMTarg);
    end
end
clear trainTmp;
cd(headFile{1});
MIDs = getMIDsForRFshim(headFile{1});
[UP_coeffs,~,~] = acshim(MIDs,'ueBZ',vars); %the actual optimization

vars.coeffs = UP_coeffs./abs(UP_coeffs);
%norm_CP = sqrt(length(coeffs)); %% sqrt(8)
%varss.coeffs = coeffs;

fact = [1 1 3];
[~,fitn,res] = acshim(MIDs,'eB',vars); %calc result
plotMeB1pTpV = strtch(res.shimmedTpV,fact);
cubeMeans = fitn.SmeanSVSuTpV;
SARmeans  = fitn.meanLSAR10g;
SARmax = fitn.maxLSAR10g;
%fprintf('UP: \t\t\t\t%d uT\n',fitn.SmeanSVSuTpV);

%% Do the tailored optimization
vars = rmfield(vars,'coeffs');
vars.plotTitle = 'Tailored';
%vars.Tikh = 0;
[~,fitn,res] = acshim(MIDs,'ueB1',vars);
%vars.coeffs = coeffs./abs(coeffs);
%[coeffs,fitn,~] = acshim(MIDs,'m4eB',vars);
%resc = norm_CP/norm(coeffs);
plotMeB1pTpV = cat(4,plotMeB1pTpV,strtch(res.shimmedTpV,fact));
cubeMeans = cat(1,cubeMeans,fitn.SmeanSVSuTpV);
SARmeans  = cat(1,SARmeans,fitn.meanLSAR10g);
SARmax = cat(1,SARmax,fitn.maxLSAR10g);
%fprintf('Tailored: \t\t\t%d uT\n',fitn.SmeanSVSuTpV);
%% Do the Tailored-Net prediction
vars.coeffs = predictAndConstructRFSetting(tailoredNet,[testTargetCoord vars.GaussMask(1)]);
vars.coeffs = vars.coeffs./abs(vars.coeffs);
vars.plotTitle = 'Tailored-Net';
[~,fitn,res] = acshim(MIDs,'eB',vars);
%resc = norm_CP/norm(vars.coeffs);
plotMeB1pTpV = cat(4,plotMeB1pTpV,strtch(res.shimmedTpV,fact));
cubeMeans = cat(1,cubeMeans,fitn.SmeanSVSuTpV);
SARmeans  = cat(1,SARmeans,fitn.meanLSAR10g);
SARmax = cat(1,SARmax,fitn.maxLSAR10g);
%fprintf('Tailored-Net: \t\t%d uT\n',fitn.SmeanSVSuTpV);
%% Do the RF-UP-Net prediction
vars.coeffs = predictAndConstructRFSetting(RFUPNet,[testTargetCoord vars.GaussMask(1)]);
vars.coeffs = vars.coeffs./abs(vars.coeffs);
vars.plotTitle = 'RF-UP-Net';
[~,fitn,res] = acshim(MIDs,'eB',vars);
%resc = norm_CP/norm(vars.coeffs);
plotMeB1pTpV = cat(4,plotMeB1pTpV,strtch(res.shimmedTpV,fact));
cubeMeans = cat(1,cubeMeans,fitn.SmeanSVSuTpV);
SARmeans  = cat(1,SARmeans,fitn.meanLSAR10g);
SARmax = cat(1,SARmax,fitn.maxLSAR10g);
%fprintf('RF-UP-Net: \t\t\t%d uT\n',fitn.SmeanSVSuTpV);

%% Weighted CP-mode performance
%fprintf('WCP-mode: \t\t\t%d uT\n',fitn.WmeanSVSuTpV);
plotMeB1pTpV = cat(4,plotMeB1pTpV,strtch(res.wcp_shimmedTpV,fact));
cubeMeans = cat(1,cubeMeans,fitn.WmeanSVSuTpV);
SARmeans  = cat(1,SARmeans,fitn.wcp_meanLSAR10g);
SARmax = cat(1,SARmax,fitn.wcp_maxLSAR10g);

%% CP-mode performance
vars.coeffs = ones(8,1);
[~,fitn,res] = acshim(MIDs,'eB',vars);
plotMeB1pTpV = cat(4,plotMeB1pTpV,strtch(res.shimmedTpV,fact));
cubeMeans = cat(1,cubeMeans,fitn.SmeanSVSuTpV);
SARmeans  = cat(1,SARmeans,fitn.meanLSAR10g);
SARmax = cat(1,SARmax,fitn.maxLSAR10g);

plotMeB1pTpV = cat(4,plotMeB1pTpV,strtch(res.MTarg,fact)*0.1);
%% Stretch the masks
posn = vars.GaussMCnt.*fact;
convBox = 2*ceil((vars.svsBoxSize/2)./tmppp.aux.Res)+1;
% SVS-cube for plotting
Msvs = zeros(size(tmppp.Mspm));
try
    Msvs(vars.GaussMCnt(1)-(convBox(1)-1)/2:vars.GaussMCnt(1)+(convBox(1)-1)/2,...
        vars.GaussMCnt(2)-(convBox(2)-1)/2:vars.GaussMCnt(2)+(convBox(2)-1)/2,...
        vars.GaussMCnt(3)-(convBox(3)-1)/2:vars.GaussMCnt(3)+(convBox(3)-1)/2) = true;
    assert(isequal(size(Msvs),size(tmppp.Mspm)));
catch
    if isfield(vars,'verbose') && vars.verbose > 0
        warning('The SVS-box is out of range! Using the convolution method instead. (Same result, but slower)')
    end
    Msvs = zeros(size(tmppp.Mspm));
end

M = strtch(tmppp.Mspm,fact);
Msvs = strtch(Msvs,fact);
clear tmppp;
%% Do the plotting
param.ylabels{1} = 'RF-UP';
param.ylabels{2} = 'Tailored';
param.ylabels{3} = 'Tailored-Net';
param.ylabels{4} = 'RF-UP-Net';
param.ylabels{5} = 'wCP-mode';
param.ylabels{6} = 'CP-mode';
param.ylabels{7} = 'Target';
param.clabel = ['$\mathrm{uTV^{-1}}$'];
param.type = 'cp';
%param.latexTitle = [];
param.title = 'Example comparison before V_{max} is set';
param.Msvs = Msvs;
param.means = cubeMeans;
param.SARmeans = SARmeans;
param.SARmax = SARmax;
param.dirLabels = true;
plotShimResults(abs(plotMeB1pTpV),posn,M,M,param);

    
end

function posn = getComass(prot,aux)
%% if there is an adjustment volume from the Siemens user
if  isfield(prot.MeasYaps.sAdjData, 'sAdjVolume')
    
    % where is the adjustment volume centre
    if isfield(prot.MeasYaps.sAdjData.sAdjVolume,'sPosition')
        if isfield(prot.MeasYaps.sAdjData.sAdjVolume.sPosition,'dCor')
            if ischar(prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dCor)
                prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dCor= str2num(prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dCor);
            end
            VOIcntr(2) = -prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dCor./1000;
        end
        if isfield(prot.MeasYaps.sAdjData.sAdjVolume.sPosition,'dSag')
            if ischar(prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dSag)
                prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dSag= str2num(prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dSag);
            end
            VOIcntr(1) = prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dSag./1000;
        end
        if isfield(prot.MeasYaps.sAdjData.sAdjVolume.sPosition,'dTra')
            if ischar(prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dTra)
                prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dTra= str2num(prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dTra);
            end
            VOIcntr(3) = -prot.MeasYaps.sAdjData.sAdjVolume.sPosition.dTra./1000;
        end
    end
    [~, posn(1)] = min(abs(aux.coords{1}-VOIcntr(1)));
    [~, posn(2)] = min(abs(aux.coords{2}-VOIcntr(2)));
    [~, posn(3)] = min(abs(aux.coords{3}-VOIcntr(3)));
    
else
    posn = -1;
end
end