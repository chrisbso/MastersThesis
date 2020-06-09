%% Plot the results from compareRFShimmingMethods
function [bFigs,maxSARFigs,meanSARFigs,ratioFigs] = plotCompareRFSM(meanB1puTpV,maxSAR,meanSAR,idxsOrdered)
%PLOTCOMPARERFSM Plot the RF Shimming comparisons
%   Detailed explanation goes here

assert(isequal(size(meanB1puTpV),size(maxSAR),size(meanSAR)));
for i = 1:length(idxsOrdered)
    coB1p  = meanB1puTpV(:,i);
    coMax = maxSAR(:,i);
    coMean = meanSAR(:,i);
    %coResc = rescaleFactor(:,i);
    filee = getReconstructedFilesCellArr(idxsOrdered(i));
    tmpp = load(filee{1},'aux','Mspm','prot');
    
    %try to get comass from adjVolMask-code
    posn = getComass(tmpp.prot,tmpp.aux);
    %if it failed (i.e returned -1) use cntr
    if isequal(posn,-1)
        % find comass
        [~,posn(1)] = min(abs(tmpp.aux.coords{1}-tmpp.aux.cntr(1)));
        [~,posn(2)] = min(abs(tmpp.aux.coords{2}-tmpp.aux.cntr(2)));
        [~,posn(3)] = min(abs(tmpp.aux.coords{3}-tmpp.aux.cntr(1)));
    end
    fact = [1 1 3];
    % stretch the stuff
    posn = posn.*fact;
    M = strtch(tmpp.Mspm,fact);
    plotMeB1p   = strtch(coB1p{1}, fact);
    plotMeMax  = strtch(coMax{1}, fact);
    plotMeMean = strtch(coMean{1}, fact);
    plotMeVmax_with_LSAR10Wpkg = strtch(10/(coMax{1}), fact); %Vmax^2
    plotMeVmax_with_ASAR32Wpkg = strtch(3.2/(coMean{1}),fact); %Vmax^2
    means = mean(coB1p{1}(:));
    stds = std(coB1p{1}(:));
    for j = 2:length(coB1p)
        plotMeB1p  = cat(4,plotMeB1p,strtch(coB1p{j}, fact));
        plotMeMax = cat(4,plotMeMax,strtch(coMax{j}, fact));
        plotMeMean = cat(4,plotMeMean,strtch(coMean{j}, fact));
        plotMeVmax_with_LSAR10Wpkg = cat(4,plotMeVmax_with_LSAR10Wpkg,strtch(10/(coMax{j}), fact));
        plotMeVmax_with_ASAR32Wpkg = cat(4,plotMeVmax_with_ASAR32Wpkg,strtch(3.2/(coMean{j}),fact));
        means = cat(1,means,mean(coB1p{j}(:)));
        stds = cat(1,stds,std(coB1p{j}(:)));
    end
    plotMeVmax_with_LSAR10Wpkg = sqrt(plotMeVmax_with_LSAR10Wpkg); %VMax
    plotMeVmax_with_ASAR32Wpkg = sqrt(plotMeVmax_with_ASAR32Wpkg);
    plotMeVmax_SARConstrained = min(plotMeVmax_with_ASAR32Wpkg,plotMeVmax_with_LSAR10Wpkg);
    plotMeB1p_with_LSAR10Wpkg = plotMeB1p.*plotMeVmax_with_LSAR10Wpkg;
    plotMeB1p_with_ASAR32Wpkg = plotMeB1p.*plotMeVmax_with_ASAR32Wpkg;
    plotMeB1p_SARConstrained = plotMeB1p.*plotMeVmax_SARConstrained;
    %plot params
    
    %param.means = means;
    %param.stds = stds;  
    param.ylabels{1} = 'RF-UP';
    param.ylabels{2} = 'Tailored';
    param.ylabels{3} = 'Tailored-N.';
    param.ylabels{4} = 'RF-UP-N.';
    param.ylabels{5} = 'wCP';
    param.ylabels{6} = 'CP';
    param.isconv = true;
    param.clabel = ['uT/V'];
    param.type = 'cp';
    param.title = ['(SVS-cube-means) / V_{max} of scan ' num2str(idxsOrdered(i))];
    param.dirLabels = true;
    bFigs(i) = plotShimResults(plotMeB1p,posn,M,M,param);
    %param = rmfield(param,'means');
    %param = rmfield(param,'stds');
    
    
    param.title = {'Max(SAR_{10g}) / V_{max}^{2} for best-case',['SVS-cube-means of scan ' num2str(idxsOrdered(i))]};
    param.clabel = '$\mathrm{W{(kg)}^{-1}V^{-2}}$';
    maxSARFigs(i) = plotShimResults(plotMeMax,posn,M,M,param);
    
    param.title = {'Mean(SAR_{10g}) / V_{max}^{2} for best-case',['SVS-cube-means of scan ' num2str(idxsOrdered(i))]};
    param.clabel = '$\mathrm{W{(kg)}^{-1}V^{-2}}$';
    meanSARFigs(i) = plotShimResults(plotMeMean,posn,M,M,param);
    
%     param.title = ['Vmax for best-case SVS-cube-means reaching maxLSAR = 10W/kg of scan' num2str(idxsOrdered(i))];
%     param.clabel = 'V';
%     maxRatioFigs(i) = plotShimResults(plotMeVmax_with_LSAR10Wpkg,posn,M,M,param);
        maxRatioFigs(i) = -1;
        
%     param.title = ['Vmax for best-case SVS-cube-means reaching maxASAR = 3.2W/kg of scan' num2str(idxsOrdered(i))];
%     param.clabel = 'V';
%     meanRatioFigs(i) = plotShimResults(plotMeVmax_with_ASAR32Wpkg,posn,M,M,param);
        meanRatioFigs(i) = -2;
%     
    
%     param.title = {'Best-case SVS-cube-means reaching',['maxLSAR = 10W/kg of scan ' num2str(idxsOrdered(i))]};
%     param.clabel = 'uT';
%     limMaxSARFigs(i) = plotShimResults(plotMeB1p_with_LSAR10Wpkg,posn,M,M,param);
%     
%     param.title = {'Best-case SVS-cube-means reaching',['maxASAR = 3.2W/kg of scan ' num2str(idxsOrdered(i))]};
    param.clabel = 'uT';
%     limMaxSARFigs(i) = plotShimResults(plotMeB1p_with_ASAR32Wpkg,posn,M,M,param);

%     
    param.title = {'Best-case SVS-cube-means',['within IEC SAR-limits of scan ' num2str(idxsOrdered(i))]};
    plotShimResults(plotMeB1p_SARConstrained,posn,M,M,param);
end
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
