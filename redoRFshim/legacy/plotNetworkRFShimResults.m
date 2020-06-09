%% Plot the results from compareRFShimMethods.m

function h = plotNetworkRFShimResults(avgNRMSEs,nTrain,nTest,lenTestIdxs,layerSizes,plotType)
%% Run these first if you haven't properly set up the workspace variables yet.
% avgNRMSEs.avgNRMSE_JO = avgNRMSE_JO;
% avgNRMSEs.avgNRMSE_tail = avgNRMSE_tail;
% avgNRMSEs.avgNRMSE_nets_JO = avgNRMSE_nets_JO;
% avgNRMSEs.avgNRMSE_nets_NJO = avgNRMSE_nets_NJO;
% layerSizes = [firstLayerSizes;secondLayerSizes;thirdLayerSizes];


%% Do the plotting if you have many nets to compare (plotType == 'graph')
if strcmp(plotType,'graph')
    h = figure;
    plot(nTrain,avgNRMSEs.avgNRMSE_nets_JO,'-o');
    hold on;
    plot(nTrain,repmat(avgNRMSEs.avgNRMSE_JO,8,1),':','LineWidth',2);
    plot(nTrain,avgNRMSEs.avgNRMSE_nets_NJO,'--*');

    plot(nTrain,repmat(avgNRMSEs.avgNRMSE_tail,8,1),':','LineWidth',2);

    %Set up axes
    yLimMinn = 0.95*(avgNRMSEs.avgNRMSE_tail);
    yLimMaxx = 1.04*max([avgNRMSEs.avgNRMSE_nets_JO(:);avgNRMSEs.avgNRMSE_nets_NJO(:)]);
    ylim([yLimMinn yLimMaxx]);
    xlim([nTrain(1) nTrain(end)]);

    % Labels and stuff
    labelss = makeNiceLegendLabels(layerSizes);
    legend([labelss,'RF-UP',labelss,'Tailored'],'NumColumns',2);

    title(['Network performance comparison']);
    ylabel('Average NRMSE','FontSize',20);
    xlabel('# of training examples','FontSize',20);
    dim = [.17 .595 .3 .3];
    str1 = ['Averaged over ' num2str(lenTestIdxs*nTest) ' test examples'];
    str2 = ['(' num2str(nTest) ' mask positions over 3 unseen volunteers)'];

    annotation('textbox',dim,'String',{str1,str2},'FitBoxToText','on','HorizontalAlignment','center');
    set(gca,'FontSize',12);
    set(h,'Position',[362 586 878 392]);
    
    %% Do the plotting if you have just two nets to compare (plotType == 'bar')
elseif strcmp(plotType,'bar')
    h = figure;
    X = categorical({'Test-Tailored','Train-UP','Train-UP Net','Train-Tailored Net'});
    X = reordercats(X,{'Test-Tailored','Train-UP','Train-UP Net','Train-Tailored Net'});
    Y = [avgNRMSEs.avgNRMSE_tail avgNRMSEs.avgNRMSE_JO avgNRMSEs.avgNRMSE_nets_JO avgNRMSEs.avgNRMSE_nets_NJO];
    bar(X,Y);
    title('RF-shimming performance comparison');
    % Set up the y-axis
    ylabel('Average NRMSE');
    yLimMinn = 0.99*(avgNRMSEs.avgNRMSE_tail);
    yLimMaxx = 1.01*max([avgNRMSEs.avgNRMSE_nets_JO(:);avgNRMSEs.avgNRMSE_nets_NJO(:)]);
    ylim([yLimMinn yLimMaxx]);
    % Set up annotations
    str1 = ['Averaged over ' num2str(lenTestIdxs*nTest) ' test examples'];
    str2 = ['(' num2str(nTest) ' mask positions over 3 unseen volunteers)'];
    dim = [2.5 yLimMaxx*0.995];
    text(dim(1),dim(2),{str1,str2},'FontSize',12,'HorizontalAlignment','center');
    
    set(gca,'FontSize',12);
    set(h,'Position',[145.0000  293.0000  476.8000  424.0000]);
    
elseif strcmp(plotType,'hist')
    % Run these if you haven't set up the workspace
    %     avgNRMSEs.NRMSE_JO = NRMSE_JO;
    %     avgNRMSEs.NRMSE_tail = NRMSE_tail;
    %     avgNRMSEs.NRMSE_nets_JO = NRMSE_nets_JO;
    %     avgNRMSEs.NRMSE_nets_NJO = NRMSE_nets_NJO;
    %     layerSizes = [firstLayerSizes;secondLayerSizes;thirdLayerSizes];
    
    h = figure();
    
    tail        = avgNRMSEs.NRMSE_tail(:);
    JO          = avgNRMSEs.NRMSE_JO(:);
    nets_NJO    = avgNRMSEs.NRMSE_nets_NJO(:);
    nets_JO     = avgNRMSEs.NRMSE_nets_JO(:);
    
    bins = 256;
    histlim = [ min([tail; JO;nets_NJO;nets_JO])  max([tail; JO;nets_NJO;nets_JO]) ];
    bns = linspace(histlim(1),histlim(2),bins);

    sTail.std   = std(tail);
    sTail.mean  = mean(tail);

    sJO.std   = std(JO);
    sJO.mean  = mean(JO);

    sNets_NJO.std   = std(nets_NJO);
    sNets_NJO.mean  = mean(nets_NJO);

    sNets_JO.std   = std(nets_JO);
    sNets_JO.mean  = mean(nets_JO);

    clear frq
    [frq(:,1)] = hist(tail,bns);
    [frq(:,2)] = hist(JO,bns);
    [frq(:,3)] = hist(nets_NJO,bns);
    [frq(:,4)] = hist(nets_JO,bns);

    subplot(411)
    hold on
    plot([sTail.mean sTail.mean],[0 1.4*max(frq(:))],'k--','LineWidth',2)
    area(bns,frq(:,1));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('NRMSE')
    ylabel('# of ex.')
    title('Pulses tailored to test volunteers')
    legend(['Mean = ' num2str(sTail.mean,'%5.5f')], ...
            'Location','NorthEast')

    subplot(412)
    hold on
    plot([sJO.mean sJO.mean],[0 1.4*max(frq(:))],'k--','LineWidth',2)
    area(bns,frq(:,2));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('NRMSE')
    ylabel('# of ex.')
    title('UPs optimized over training volunteers')
    legend(['Mean = ' num2str(sJO.mean,'%5.5f')], ...
            'Location','NorthEast')
        
    subplot(413)
    hold on
    plot([sNets_NJO.mean sNets_NJO.mean],[0 1.4*max(frq(:))],'k--','LineWidth',2)
    area(bns,frq(:,3));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('NRMSE')
    ylabel('# of ex.')
    title('Prediction from network trained on pulses tailored to training volunteers')
    legend(['Mean = ' num2str(sNets_NJO.mean,'%5.5f')], ...
            'Location','NorthEast')
    
    subplot(414)
    hold on
    plot([sNets_JO.mean sNets_JO.mean],[0 1.4*max(frq(:))],'k--','LineWidth',2)
    area(bns,frq(:,4));
    xlim([histlim])
    ylim([0 1.4*max(frq(:))])
    xlabel('NRMSE')
    ylabel('# of ex.')
    title('Prediction from network trained on UPs optimized to training volunteers')
    legend(['Mean = ' num2str(sNets_JO.mean,'%5.5f')], ...
            'Location','NorthEast')
    hold off;
else
    error('Please specify the plot type you want with argument "plotType", either "bar" or "graph".')
end

end


%% A little help function to format the legend entries
function labelss = makeNiceLegendLabels(layerSizes)
    siz = size(layerSizes);
    labelss = repmat("",siz(1),1);
    for i = 1:siz(1)
        for j = 1:siz(2)
            labelss(i) = labelss(i) + num2str(layerSizes(j,i)) + "-"; 
        end
        labelss(i) = labelss(i) + "15-";
    end
   
    labelss = [labelss repmat('net',siz(1),1)];
    labelss = join(labelss,"");
    labelss = labelss';
end