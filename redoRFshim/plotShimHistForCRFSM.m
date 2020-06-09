%% Plot the histograms for compareRFShimmingMethods
function plotShimHistForCRFSM(meanB1puTpV,maxSAR,meanSAR,idxsOrdered) 

bins = 128;

for i = 1:length(idxsOrdered)
    maxSARlim = 10;
    meanSARlim = 3.2;
    rfupVMax = sqrt(min(maxSARlim./maxSAR{1,i},meanSARlim./meanSAR{1,i}));
    rfupVMax(isinf(rfupVMax)) = 0;
    tailVMax = sqrt(min(maxSARlim./maxSAR{2,i},meanSARlim./meanSAR{2,i}));
    tailVMax(isinf(tailVMax)) = 0;
    tailNVMax = sqrt(min(maxSARlim./maxSAR{3,i},meanSARlim./meanSAR{3,i}));
    tailNVMax(isinf(tailNVMax)) = 0;
    rfupNVMax = sqrt(min(maxSARlim./maxSAR{4,i},meanSARlim./meanSAR{4,i}));
    rfupNVMax(isinf(rfupNVMax)) = 0;
    wCPVMax = sqrt(min(maxSARlim./maxSAR{5,i},meanSARlim./meanSAR{5,i}));
    wCPVMax(isinf(wCPVMax)) = 0;
    CPVMax = sqrt(min(maxSARlim./maxSAR{6,i},meanSARlim./meanSAR{6,i}));
    CPVMax(isinf(CPVMax)) = 0;
    
    rfupB = meanB1puTpV{1,i}.*rfupVMax;
    tailB = meanB1puTpV{2,i}.*tailVMax;
    tailNB = meanB1puTpV{3,i}.*tailNVMax;
    rfupNB = meanB1puTpV{4,i}.*rfupNVMax;
    wCPB = meanB1puTpV{5,i}.*wCPVMax;
    CPB = meanB1puTpV{6,i}.*CPVMax;

    
    figure('Position',[790.6 65 416.8 635.2]);
    %figure('Position',[601 1 600 600])
    rfupB = abs(rfupB(find(rfupB)));
    tailB = abs(tailB(find(tailB)));
    tailNB = abs(tailNB(find(tailNB)));
    rfupNB = abs(rfupNB(find(rfupNB)));
    wCPB = abs(wCPB(find(wCPB)));
    CPB = abs(CPB(find(CPB)));


    %histlim = [ min([rfupB; tailB; tailNB; rfupNB; wCPB; CPB])  max([rfupB; tailB; tailNB; rfupNB; wCPB; CPB]) ];
    histlim = [ min([rfupB; tailB; tailNB; rfupNB; wCPB; CPB]) 20 ];
    
    bns = linspace(histlim(1),histlim(2),bins);

    rfup.std   = std( rfupB);
    rfup.mean  = mean(rfupB);

    tail.std   = std( tailB);
    tail.mean  = mean(tailB);

    tailN.std = std(tailNB);
    tailN.mean = mean(tailNB);
    
    rfupN.std = std(rfupNB);
    rfupN.mean = mean(rfupNB);
    
    wCP.std = std(wCPB);
    wCP.mean = mean(wCPB);
    
    CP.std = std(CPB);
    CP.mean = mean(CPB);
    
    clear frq
    [frq(:,1)] = hist(rfupB,bns);
    [frq(:,2)] = hist(tailB,bns);
    [frq(:,3)] = hist(tailNB,bns);
    [frq(:,4)] = hist(rfupNB,bns);
    [frq(:,5)] = hist(wCPB,bns);
    [frq(:,6)] = hist(CPB,bns);
    
    title('Scan..');
    subplot(611)
    hold on
    axis manual;
    plot([rfup.mean rfup.mean],[0 1.4*max(frq(:))],'k--')
    plot([rfup.mean+rfup.std/2 rfup.mean+rfup.std/2 ...
            rfup.mean-rfup.std/2 rfup.mean-rfup.std/2], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'r--')
    plot([prctile(rfupB,95) prctile(rfupB,95) ...
            prctile(rfupB,5) prctile(rfupB,5)], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'g--')
    area(bns,frq(:,1));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('RF-amplitude (uT)')
    ylabel('#Voxels')
    title(['RF-UP, $\mu\pm\sigma=$ (' num2str(rfup.mean,'%2.2f') ' $\pm$ ' num2str(rfup.std,'%2.2f') ') $\mathrm{uT}$'],'Interpreter','latex','FontSize',12)
%     legend(['Mean = ' num2str(rfup.mean,'%5.2f') ' deg'], ...
%             ['Standard Deviation = ' num2str(rfup.std,'%5.2f') ' deg'], ...
%             ['90^{th} Percentile Range = ' num2str(  prctile(rfupB,95)-prctile(rfupB,5),'%5.2f') ' deg'],...
%             'Location','NorthEast')
%         
    subplot(612)
    hold on
    axis manual;
    plot([tail.mean tail.mean],[0 1.4*max(frq(:))],'k--')
    plot([tail.mean+tail.std/2 tail.mean+tail.std/2 ...
            tail.mean-tail.std/2 tail.mean-tail.std/2], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'r--')
    plot([prctile(tailB,95) prctile(tailB,95) ...
            prctile(tailB,5) prctile(tailB,5)], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'g--')
    area(bns,frq(:,2));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('RF-amplitude (uT)')
    ylabel('#Voxels')
    title(['Tailored, $\mu\pm\sigma=$ (' num2str(tail.mean,'%2.2f') ' $\pm$ ' num2str(tail.std,'%2.2f') ') $\mathrm{uT}$'],'Interpreter','latex','FontSize',12)
%     legend(['Mean = ' num2str(tail.mean,'%5.2f') ' uT'], ...
%             ['Standard Deviation = ' num2str(tail.std,'%5.2f') ' uT'], ...
%             ['90^{th} Percentile Range = ' num2str(  prctile(tailB,95)-prctile(tailB,5),'%5.2f') ' uT'],...
%             'Location','NorthEast')

    subplot(613)
    hold on
        axis manual;
    plot([tailN.mean tailN.mean],[0 1.4*max(frq(:))],'k--')
    plot([tailN.mean+tailN.std/2 tailN.mean+tailN.std/2 ...
            tailN.mean-tailN.std/2 tailN.mean-tailN.std/2], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'r--')
    plot([prctile(tailNB,95) prctile(tailNB,95) ...
            prctile(tailNB,5) prctile(tailNB,5)], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'g--')
    area(bns,frq(:,3));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('RF-amplitude (uT)')
    ylabel('#Voxels')
    title(['Tailored-Net, $\mu\pm\sigma=$ (' num2str(tailN.mean,'%2.2f') ' $\pm$ ' num2str(tailN.std,'%2.2f') ') $\mathrm{uT}$'],'Interpreter','latex','FontSize',12)
%     legend(['Mean = ' num2str(tailN.mean,'%5.2f') ' uT'], ...
%             ['Standard Deviation = ' num2str(tailN.std,'%5.2f') ' uT'], ...
%             ['90^{th} Percentile Range = ' num2str(  prctile(tailNB,95)-prctile(tailNB,5),'%5.2f') ' uT'],...
%             'Location','NorthEast')
    
    subplot(614)
    hold on
    axis manual;
    plot([rfupN.mean rfupN.mean],[0 1.4*max(frq(:))],'k--')
    plot([rfupN.mean+rfupN.std/2 rfupN.mean+rfupN.std/2 ...
            rfupN.mean-rfupN.std/2 rfupN.mean-rfupN.std/2], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'r--')
    plot([prctile(rfupNB,95) prctile(rfupNB,95) ...
            prctile(rfupNB,5) prctile(rfupNB,5)], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'g--')
    area(bns,frq(:,4));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('RF-amplitude (uT)')
    ylabel('#Voxels')
    title(['RF-UP-Net, $\mu\pm\sigma=$ (' num2str(rfupN.mean,'%2.2f') ' $\pm$ ' num2str(rfupN.std,'%2.2f') ') $\mathrm{uT}$'],'Interpreter','latex','FontSize',12)
%     legend(['Mean = ' num2str(rfupN.mean,'%5.2f') ' uT'], ...
%             ['Standard Deviation = ' num2str(rfupN.std,'%5.2f') ' uT'], ...
%             ['90^{th} Percentile Range = ' num2str(  prctile(rfupNB,95)-prctile(rfupNB,5),'%5.2f') ' uT'],...
%             'Location','NorthEast')
        
    subplot(615)
    hold on
    axis manual;
    plot([wCP.mean wCP.mean],[0 1.4*max(frq(:))],'k--')
    plot([wCP.mean+wCP.std/2 wCP.mean+wCP.std/2 ...
            wCP.mean-wCP.std/2 wCP.mean-wCP.std/2], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'r--')
    plot([prctile(wCPB,95) prctile(wCPB,95) ...
            prctile(wCPB,5) prctile(wCPB,5)], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'g--')
    area(bns,frq(:,5));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('RF-amplitude (uT)')
    ylabel('#Voxels')
    title(['wCP, $\mu\pm\sigma=$ (' num2str(wCP.mean,'%2.2f') ' $\pm$ ' num2str(wCP.std,'%2.2f') ') $\mathrm{uT}$'],'Interpreter','latex','FontSize',12)
%     legend(['Mean = ' num2str(wCP.mean,'%5.2f') ' uT'], ...
%             ['Standard Deviation = ' num2str(wCP.std,'%5.2f') ' uT'], ...
%             ['90^{th} Percentile Range = ' num2str(  prctile(wCPB,95)-prctile(wCPB,5),'%5.2f') ' uT'],...
%             'Location','NorthEast')

    subplot(616)
    hold on
    axis manual;
    plot([CP.mean CP.mean],[0 1.4*max(frq(:))],'k--')
    plot([CP.mean+CP.std/2 CP.mean+CP.std/2 ...
            CP.mean-CP.std/2 CP.mean-CP.std/2], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'r--')
    plot([prctile(CPB,95) prctile(CPB,95) ...
            prctile(CPB,5) prctile(CPB,5)], ...
            [1.4*max(frq(:)) 0 0 1.4*max(frq(:))],'g--')
    area(bns,frq(:,6));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('RF-amplitude (uT)')
    ylabel('#Voxels')
    title(['CP, $\mu\pm\sigma=$ (' num2str(CP.mean,'%2.2f') ' $\pm$ ' num2str(CP.std,'%2.2f') ') $\mathrm{uT}$'],'Interpreter','latex','FontSize',12)
%     legend(['Mean = ' num2str(CP.mean,'%5.2f') ' uT'], ...
%             ['Standard Deviation = ' num2str(CP.std,'%5.2f') ' uT'], ...
%             ['90^{th} Percentile Range = ' num2str(  prctile(CPB,95)-prctile(CPB,5),'%5.2f') ' uT'],...
%             'Location','NorthEast')




    hold off
end %for idxs
end %function