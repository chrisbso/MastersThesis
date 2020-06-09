%% Compare the different shimming mettestIdxhods (Tailored, UP, NET-JOUP, NET-UP)
function [meanB1puTpV,meanSARpUDC_Vsq,maxSARpUDC_Vsq] = compareRFShimMethods(parentDir,saveDir,testIdxs,trainIdxs,tailoredNet,RFUPNet,nIter)
%% Set up parent directory if not specified
if isempty(parentDir)
    parentDir = 'D:\NN_training_data\heads';
end

if isempty(saveDir)
    saveDir = 'D:\NN_training_data\';
end

%% Set up file locations
testFiles       = getHeadFilesCellArr(testIdxs,parentDir); 
testRecFiles    = getReconstructedFilesCellArr(testIdxs,parentDir); 

trainFiles      = getHeadFilesCellArr(trainIdxs,parentDir);
trainRecFiles   = getReconstructedFilesCellArr(trainIdxs,parentDir);

%% Find out what folder you're running this in, and load the proper workspace variables;
funcFold = mfilename('fullpath');
[~,funcFold] = strtok(fliplr(funcFold),slsh);
funcFold = fliplr(funcFold);

tmpp = load([funcFold 'acshimVars1.mat'],'vars');
vars = tmpp.vars;
vars.GaussMask = repmat(0.01,1,3);
vars.svsBoxSize = [20 20 20];
clear tmpp

%% Set up the cell holding the calculated mean of the B1p.
meanB1puTpV    = cell(6,length(testRecFiles));
meanSARpUDC_Vsq  = cell(6,length(testRecFiles));
maxSARpUDC_Vsq = cell(6,length(testRecFiles));
    for i = 1:length(testRecFiles)
        tmp = load(testRecFiles{i},'Mspm');
        meanB1puTpV(:,i)    = {zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));...
            zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));zeros(size(tmp.Mspm))};
        meanSARpUDC_Vsq(:,i)  = {zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));...
            zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));zeros(size(tmp.Mspm))};
        maxSARpUDC_Vsq(:,i)  = {zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));...
            zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));zeros(size(tmp.Mspm));zeros(size(tmp.Mspm))};
    end

%% Set up the b1p's for the joint optimization (done over test files)
for i = 1:length(trainRecFiles)
            tmp = load(trainRecFiles{i},'b1p_kt'); %%this "_kt"-part already done the weird phase-shifting
            if i == 1
                vars.catB1p = tmp.b1p_kt;
            else
                vars.catB1p = cat(3,vars.catB1p,tmp.b1p_kt);
            end
end        
clear tmp;

%% Check how much you want to do (if you've specified "nIter" or not)
if nargin > 6
    nIter = repmat(nIter,1,length(testFiles));
    fixedIters = true;

else
    nIter = zeros(1,length(testRecFiles));
    for i = 1:length(nIter)
        tmp = load(testRecFiles{i},'Mspm');
        nIter(i) = numel(find(tmp.Mspm));
    end
    fixedIters = false;
end
clear tmp;

%% Do the calculations
%ppm = ParforProgressbar(numel(nIter));
WaitMessage = parfor_wait(sum(nIter), 'Waitbar', true);
parfor i = 1:length(testFiles)
    varss = vars;
    testTmp = load(testRecFiles{i},'Mspm','aux'); %get the brain mask for the given scan
    [h,w,d] = ind2sub(size(testTmp.Mspm),find(testTmp.Mspm)); %get all voxels within brain mask
    %hh = zeros(nIter,1);ww = zeros(nIter,1);dd=zeros(nIter,1); %set up voxels to optimize to
    posnn = zeros(1,3);
    MIDs = getMIDsForRFshim(testFiles{i});
    nIter_i = nIter(i);
    parmeanB1puTpV = meanB1puTpV(:,i);
    parmeanSARpUDC_Vsq  = meanSARpUDC_Vsq(:,i);
    parmaxSARpUDC_Vsq  = maxSARpUDC_Vsq(:,i);
    for j = 1:nIter_i %choose voxel within brain mask to optimize to
        if fixedIters
            rIdx = randi(length(h)); %random idxs
            hh = h(rIdx);ww = w(rIdx);dd = d(rIdx); %set optimize voxels
            h(rIdx) = [];w(rIdx) = []; d(rIdx) = [];  %remove them from "all voxels within brain mask"
            %(line above is to avoid optimizing several time to same voxel)
            
        else %not defined any iters, run through the whole head, pick them out sequentially for speed
            hh = h(j);ww = w(j);dd = d(j);
        end
        testTargetCoord = [testTmp.aux.coords{1}(hh) testTmp.aux.coords{2}(ww) testTmp.aux.coords{3}(dd)];
        %% Do the joint optimization
        for k = 1:length(trainFiles)
            trainTmp = load(trainRecFiles{k},'Mspm','aux');

            %get vox coords of center of blob
            [~,posnn(1)] = min(abs(trainTmp.aux.coords{1}-testTargetCoord(1)));
            [~,posnn(2)] = min(abs(trainTmp.aux.coords{2}-testTargetCoord(2)));
            [~,posnn(3)] = min(abs(trainTmp.aux.coords{3}-testTargetCoord(3)));

            newMTarg = (trainTmp.Mspm).*gaussianmask(trainTmp.Mspm,trainTmp.aux,posnn,varss.GaussMask);
            if k == 1
                varss.catMTarg = newMTarg;
            else
                varss.catMTarg = cat(3,varss.catMTarg,newMTarg);
            end
        end
        cd(testFiles{i});
        %not really important which MID you put in here
        %varss.Tikh = 0;
        [coeffs,~,~] = acshim(MIDs,'ueBZ',varss); %the actual optimization
        
        varss.coeffs = coeffs./abs(coeffs);
        %varss.coeffs = coeffs;
        %norm_CP = sqrt(length(coeffs)); %% sqrt(8)
        %varss.coeffs = coeffs;
        varss.GaussMCnt = [hh ww dd];
        varss.plotTitle = 'RF-UP';
        [~,fitn,~] = acshim(MIDs,'eB',varss); %calc result
        %resc = norm_CP/norm(varss.coeffs);
        parmeanB1puTpV{1,1}(hh,ww,dd) = fitn.SmeanSVSuTpV;
        parmeanSARpUDC_Vsq{1,1}(hh,ww,dd)  = fitn.meanLSAR10g;
        parmaxSARpUDC_Vsq{1,1}(hh,ww,dd) = fitn.maxLSAR10g;
        %fprintf('UP: \t\t\t\t%d uT\n',fitn.SmeanSVSuTpV);
        
        %% Do the tailored optimization
        varss = rmfield(varss,'coeffs');
        varss.plotTitle = 'Tailored';
        %varss.Tikh = 0;
        [~,fitn,~] = acshim(MIDs,'ueB1',varss);
        %varss.coeffs = coeffs./abs(coeffs);
        %[coeffs,fitn,~] = acshim(MIDs,'m4eB',varss);
        %resc = norm_CP/norm(coeffs);
        parmeanB1puTpV{2,1}(hh,ww,dd) = fitn.SmeanSVSuTpV;
        parmeanSARpUDC_Vsq{2,1}(hh,ww,dd)  = fitn.meanLSAR10g;
        parmaxSARpUDC_Vsq{2,1}(hh,ww,dd) = fitn.maxLSAR10g;
        %fprintf('Tailored: \t\t\t%d uT\n',fitn.SmeanSVSuTpV);
        %% Do the Tailored-Net prediction
        varss.coeffs = predictAndConstructRFSetting(tailoredNet,[testTargetCoord varss.GaussMask(1)]);
        varss.coeffs = varss.coeffs./abs(varss.coeffs);
        varss.plotTitle = 'Tailored-Net';
        [~,fitn,~] = acshim(MIDs,'eB',varss);
        %resc = norm_CP/norm(varss.coeffs);
        parmeanB1puTpV{3,1}(hh,ww,dd) = fitn.SmeanSVSuTpV;
        parmeanSARpUDC_Vsq{3,1}(hh,ww,dd)  = fitn.meanLSAR10g;
        parmaxSARpUDC_Vsq{3,1}(hh,ww,dd) = fitn.maxLSAR10g;
        %fprintf('Tailored-Net: \t\t%d uT\n',fitn.SmeanSVSuTpV);
        %% Do the RF-UP-Net prediction
        varss.coeffs = predictAndConstructRFSetting(RFUPNet,[testTargetCoord varss.GaussMask(1)]);
        varss.coeffs = varss.coeffs./abs(varss.coeffs);
        varss.plotTitle = 'RF-UP-Net';
        [~,fitn,~] = acshim(MIDs,'eB',varss);
        %resc = norm_CP/norm(varss.coeffs);
        parmeanB1puTpV{4,1}(hh,ww,dd) = fitn.SmeanSVSuTpV;
        parmeanSARpUDC_Vsq{4,1}(hh,ww,dd)  = fitn.meanLSAR10g;
        parmaxSARpUDC_Vsq{4,1}(hh,ww,dd) = fitn.maxLSAR10g;
        %fprintf('RF-UP-Net: \t\t\t%d uT\n',fitn.SmeanSVSuTpV);
        
        %% Weighted CP-mode performance
        %fprintf('WCP-mode: \t\t\t%d uT\n',fitn.WmeanSVSuTpV);
        parmeanB1puTpV{5,1}(hh,ww,dd) = fitn.WmeanSVSuTpV;
        parmeanSARpUDC_Vsq{5,1}(hh,ww,dd)  = fitn.wcp_meanLSAR10g;
        parmaxSARpUDC_Vsq{5,1}(hh,ww,dd) = fitn.wcp_maxLSAR10g;
        
        %% CP-mode performance
        %varss.coeffs = ones(8,1);
        %[~,fitn,~] = acshim(MIDs,'eB',varss);
        parmeanB1puTpV{6,1}(hh,ww,dd) = fitn.UmeanSVSuTpV;
        %parmeanSARpUDC_Vsq{5,1}(hh,ww,dd)  = fitn.meanLSAR10g; %set after
        %parmaxSARpUDC_Vsq{5,1}(hh,ww,dd) = fitn.maxLSAR10g;
        %fprintf('CP-mode: \t\t\t%d uT\n\n',fitn.UmeanSVSuTpV);

        %% increment the parfor-progress-bar
        WaitMessage.Send;
    end
   varss.coeffs = ones(8,1);
   [~,fitn,~] = acshim(MIDs,'eB',varss);
   parmeanSARpUDC_Vsq{6,1}(:,:,:)  = fitn.meanLSAR10g;
   parmaxSARpUDC_Vsq{6,1}(:,:,:) = fitn.maxLSAR10g;
   %ppm.increment();
   meanB1puTpV(:,i) = parmeanB1puTpV;
   meanSARpUDC_Vsq(:,i) = parmeanSARpUDC_Vsq;
   maxSARpUDC_Vsq(:,i) = parmaxSARpUDC_Vsq;
end
%delete(ppm);
WaitMessage.Destroy;
%% Save the stuff
c = clock; % get the time and date
c = num2str(c(1:end-1)); %remove seconds
if fixedIters
    saveName = ['comparedRFSM_meanB1puTpV_and_SAR_' c(~isspace(c)) 'fixedIters' num2str(nIter(1)) '.mat'];
else
    saveName = ['comparedRFSM_meanB1puTpV_and_SAR_' c(~isspace(c)) 'allHead_opts1.mat'];
end
save([saveDir slsh saveName],'meanB1puTpV','meanSARpUDC_Vsq','maxSARpUDC_Vsq');
end


    