function NRMSE = NRMSE_jointlyOptimised(XTest,YTest,headIdxs,vars)
headFiles   = getHeadFilesCellArr(headIdxs);
RecMatFiles = getReconstructedFilesCellArr(headIdxs);
NRMSE = zeros(length(headIdxs),size(YTest,1));
opts = 'eB';

YTest = YTest'; 
coeffs = YTest(1:8,:) +1i*[zeros(1,size(YTest,2));YTest(9:end,:)];

hh = waitbar(0,'(JO Average NRMSE) Starting data generation');
for i = 1:length(headIdxs)
    load(RecMatFiles{i},'aux');
    cd(headFiles{i});
    MIDsListing = dir('*_dt_dream*.dat');
       if length(MIDsListing) ~= 1
           error('Found several DREAM-files in one folder.')
       else
           MIDsName = MIDsListing(1).name;
           MIDs = extractBetween(MIDsName,'MID','_dt');
           MIDs = str2num(MIDs{1});
       end
    
    for j = 1:size(XTest,4)
        [~,posn(1)] = min(abs(aux.coords{1}-XTest(1,1,1,j)));
        [~,posn(2)] = min(abs(aux.coords{2}-XTest(1,2,1,j)));
        [~,posn(3)] = min(abs(aux.coords{3}-XTest(1,3,1,j)));
        
        vars.GaussMCnt = posn;
        vars.GaussMask = repmat(XTest(1,4,1,j),1,3);
        vars.coeffs = coeffs(:,j);
        %vars.coeffs = conj(coeffs(:,j)); %Temp fix, as the used dat??
        [~,fitn,~] = acshim(MIDs,opts,vars);
        
        %figure()
        %pcolor(fliplr(rot90(rot90(rot90(((squeeze(res.MTarg(:,:,6)))))))))
        NRMSE(i,j) = fitn.stdFT;
        perc = floor(100*(j+(i-1)*size(XTest,4))/(length(headIdxs)*size(XTest,4)));
        waitbar(perc/100,hh,sprintf('(JO Average NRMSE) Calculating: Iter %d/%d, %d%% done...',j+(i-1)*size(XTest,4),length(headIdxs)*size(XTest,4),perc));
    end
    

end
    close(hh)
end