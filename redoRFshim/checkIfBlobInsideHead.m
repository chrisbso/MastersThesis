%% Check if the target blob's center is inside the head or not.
function bInside = checkIfBlobInsideHead(XTest,headIdxs)
RecMatFiles = getReconstructedFilesCellArr(headIdxs);
bInside = false(length(headIdxs),size(XTest,4));

%ppm = ParforProgressbar(length(headIdxs)*size(XTest,4),'title','NRMSE_tailored');
hh = waitbar(0,'Starting checking procedure...');
for i = 1:length(headIdxs)
    load(RecMatFiles{i},'aux','Mspm');
    for j = 1:size(XTest,4)

        tmpp = XTest(1,:,1,j);
        [~,posn(1)] = min(abs(aux.coords{1}-tmpp(1)));
        [~,posn(2)] = min(abs(aux.coords{2}-tmpp(2)));
        [~,posn(3)] = min(abs(aux.coords{3}-tmpp(3)));

        bInside(i,j) = Mspm(posn(1),posn(2),posn(3));
        
        perc = floor(100*(j+(i-1)*size(XTest,4))/(length(headIdxs)*size(XTest,4)));
        waitbar(perc/100,hh,sprintf('(isInside Checking procedure) Calculating: Iter %d/%d, %d%% done...',j+(i-1)*size(XTest,4),length(headIdxs)*size(XTest,4),perc));
 
    end
    %perc = floor(100*(i-1)/(length(headIdxs)));
    %waitbar(perc/100,hh,sprintf('(Tailored Average NRMSE) Calculating: Iter %d/%d, %d%% done...',i-1,length(headIdxs),perc));

end
    close(hh);
    %delete(ppm);
end
