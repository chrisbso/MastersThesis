%% Plot the comparisons between CNN, tailored and kT-up
function plotCNNComparisons(net,XTest,YTest,coeffs_up)
pred = predictAndConstruct8Ktp(net,XTest);
%coeffs_p16 = pred(:,:,1);
%coeffs_p17 = pred(:,:,2);
%clear pred;
tmp1 = pred(:,:,1);
tmp2 = pred(:,:,2);
pred(:,:,1) = pred(:,:,1)/max(abs(tmp1(:))).*exp(-1i*(angle(pred(1,1,1))));
pred(:,:,2) = pred(:,:,2)/max(abs(tmp2(:))).*exp(-1i*(angle(pred(1,1,2))));

coeffs_up = coeffs_up.*exp(-1i*(angle(coeffs_up(1,1))));
tail = zeros(8,8,size(YTest,1));
    for i = 1:size(YTest,1)
        cRe = reshape(YTest(i,1:64),8,8);
        cIm = reshape([0 YTest(i,65:end)],8,8);
        tail(:,:,i) = cRe + 1i*cIm;
    end


    
plcolors =  [1 0 0;...
             0 1 0;...
             0 0 1;...
             1 1 0;...
             1 0 1;...
             1 1 0;...
             0 0 0;...
             0.9290 0.6940 0.1250];

% for ii = 1:2        
%     figure();
%     for j = 1:8
%         subplot(2,4,j);
%         polarscatter(angle(pred(:,j,ii)),abs(pred(:,j,ii)),[],plcolors,'+','LineWidth',1) ;
%         ax = gca;
%         ax.RLim = [0 1];
%         ax.RTick = [0 0.5 1];
%         hold on;
%         
%         polarscatter(angle(tail(:,j,ii)),abs(tail(:,j,ii)),[],plcolors,'*','LineWidth',1);
%         polarscatter(angle(coeffs_up(:,j)),abs(coeffs_up(:,j)),[],plcolors,'o','LineWidth',1 );
%     end
% end

for ii = 1:2
    fi = figure();
    set(fi,'Position',[301.8000  461.8000  746.2000  300.2000]);
    subplot(2,1,1);
    x = 1:8;
    b1 = bar(1,nan,'FaceColor',[0.2 0.2 0.5],'DisplayName','Tailored');
    hold on;
    b2 = bar(1,nan,0.5,'FaceColor',[0 0.7 0.7],'DisplayName','Predicted');
    %b3 = bar(1,nan,.25,'FaceColor',[1 0 0],'DisplayName','kT-UP');
    leg = legend('AutoUpdate','off');
    legp = get(leg,'Position');
    set(leg,'Position',[.768 .46 legp(3) legp(4)]);
    
    bar(x,(abs(tail(:,:,ii))'),1.,'FaceColor',[0.2 0.2 0.5],'DisplayName','Tailored');
    xlabel('Channel #')
    ylabel('Amplitude')
    xticks(x);
    xticklabels([8 1:7]);
    title(['Comparison of predicted vs. tailored time-varying weights of scan ' num2str(ii+15)],'FontSize',12);
    hold on;
    bar(x,(abs(pred(:,:,ii))'),0.5,'FaceColor',[0 0.7 0.7],'DisplayName','Predicted');
    set(gca,'FontSize',12);
    %bar(x,(abs(coeffs_up(:,:))'),.15,'FaceColor',[1 0 0],'DisplayName','kT-UP');

    subplot(2,1,2);
    x = 1:8;
    b1 = bar(1,nan,'FaceColor',[0.2 0.2 0.5],'DisplayName','Tailored');
    hold on;
    b2 = bar(1,nan,0.5,'FaceColor',[0 0.7 0.7],'DisplayName','Predicted');
    %b3 = bar(1,nan,.25,'FaceColor',[1 0 0],'DisplayName','kT-UP');
    %legend('AutoUpdate','off');
    
    bar(x,(angle(tail(:,:,ii))'),1.,'FaceColor',[0.2 0.2 0.5],'DisplayName','Tailored');
    xlabel('Channel #')
    ylabel('Phase')
    xticks(x);
    xticklabels([8 1:7]);
    ylim([-pi pi]);
    %yticks([-pi -pi/2 0 pi/2 pi]);
    yticks([-pi pi]);
    %yticklabels({'-\pi','-\pi/2','0', '\pi/2','\pi'})
    yticklabels({'-\pi','\pi'})
    %title(['Comparison of predicted time-varying weights of scan ' num2str(ii+15)]);
    hold on;
    bar(x,(angle(pred(:,:,ii))'),0.5,'FaceColor',[0 0.7 0.7],'DisplayName','Predicted');
    set(gca,'FontSize',12);
    %bar(x,(angle(coeffs_up(:,:))'),.15,'FaceColor',[1 0 0],'DisplayName','kT-UP');

    
end

end