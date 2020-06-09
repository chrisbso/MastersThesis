function NRMSE = NRMSE_tailored(XTest,headIdxs,vars)
headFiles   = getHeadFilesCellArr(headIdxs);
RecMatFiles = getReconstructedFilesCellArr(headIdxs);
opts = 'ueB';
NRMSE = zeros(length(headIdxs),size(XTest,4));
ppm = ParforProgressbar(length(headIdxs)*size(XTest,4),'title','NRMSE_tailored');
%hh = waitbar(0,'(Tailored Average NRMSE) Starting...');
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
    
    parfor j = 1:size(XTest,4)
        posn = zeros(1,3);
        varss = vars;
        tmpp = XTest(1,:,1,j);
        [~,posn(1)] = min(abs(aux.coords{1}-tmpp(1)));
        [~,posn(2)] = min(abs(aux.coords{2}-tmpp(2)));
        [~,posn(3)] = min(abs(aux.coords{3}-tmpp(3)));
        
        varss.GaussMCnt = posn;
        varss.GaussMask = repmat(tmpp(4),1,3);
        
        [~,fitn,~] = acshim(MIDs,opts,varss);
        NRMSE(i,j) = fitn.stdFT;
        ppm.increment();
        %perc = floor(100*(j+(i-1)*size(XTest,4))/(length(headIdxs)*size(XTest,4)));
        %waitbar(perc/100,hh,sprintf('(Tailored Average NRMSE) Calculating: Iter %d/%d, %d%% done...',j+(i-1)*size(XTest,4),length(headIdxs)*size(XTest,4),perc));
 
    end
    %perc = floor(100*(i-1)/(length(headIdxs)));
    %waitbar(perc/100,hh,sprintf('(Tailored Average NRMSE) Calculating: Iter %d/%d, %d%% done...',i-1,length(headIdxs),perc));

end
    %close(hh);
    delete(ppm);
end