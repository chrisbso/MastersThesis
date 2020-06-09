%% Plot an example drop-off (here: 0.01 and 0.04)
function plotDropoffs(headIdx,parentDir)
    recFiles = getReconstructedFilesCellArr(headIdx,parentDir);
    
    tmp = load(recFiles{1},'Mspm','aux','prot');
    aux = tmp.aux;
    prot = tmp.prot;
    Mspm = tmp.Mspm;
    clear tmp;
    
    GaussMCnt = getComass(prot,aux);
    GaussSig1 = repmat(0.01,1,3);
    GaussSig2 = repmat(0.04,1,3);
    
    if isequal(GaussMCnt,-1)
        % find comass
        [~,GaussMCnt(1)] = min(abs(aux.coords{1}-aux.cntr(1)));
        [~,GaussMCnt(2)] = min(abs(aux.coords{2}-aux.cntr(2)));
        [~,GaussMCnt(3)] = min(abs(aux.coords{3}-aux.cntr(1)));
    end
    
    M1 = (Mspm).*gaussianmask(Mspm,aux,GaussMCnt,GaussSig1);
    M2 = (Mspm).*gaussianmask(Mspm,aux,GaussMCnt,GaussSig2);
    
    fact = [1 1 3];
    % stretch the stuff
    GaussMCnt = GaussMCnt.*fact;
    M1 = strtch(M1,fact);
    M2 = strtch(M2,fact);
    Mspm = strtch(Mspm,fact);
    
    param.dirLabels = true;
    param.ylabels{1} = 'Drop-off = 0.01';
    param.ylabels{2} = 'Drop-off = 0.04';
    param.clabel = '(a.u.)';
    param.type = 'cp';
    param.title = 'Example Gaussian target hot-spots centered at CoM position';
    
    plotShimResults(cat(4,M1,M2),GaussMCnt,Mspm,Mspm,param);
    
    
    
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