function plotAllComparison(rMat,rPercentile,files,headIndices,typee)
if nargin < 4
    figure();
    tiledlayout(3,6,'TileSpacing','compact','Padding','compact');
    x = 1:length(rMat);
    for i = 1:length(rMat)
        rVec = rMat(i,:);
        abovePercentile = rVec(rVec>=rPercentile);
        xAbove = x(rVec>=rPercentile);
        belowPercentile = rVec(rVec<rPercentile);
        xBelow = x(rVec<rPercentile);
        
        nexttile
        if nargin > 2
            setNmbrs = extractHeadNumberFromFiles(files);
            title(['set' num2str(setNmbrs(i))]);
        else
            title(['index ' num2str(i)]);
        end
        xlim([0 x(end)]);
        ylim([min(rMat(:))*.95 max(rMat(:))*1.05])
        hold on
        plot(xAbove,abovePercentile,'*','MarkerSize',8);
        plot(xBelow,belowPercentile,'.','MarkerSize',12);
        line(xlim,[rPercentile rPercentile],'LineStyle',':');
        for j = 1:length(xAbove)
            line([xAbove(j) xAbove(j)],[min(rVec)*0.9,abovePercentile(j)],'LineStyle','--');
        end
        xticks(x(logical(mod(x,2))));
        %files = shiftCellArray(files);
    end
else 
    bMat = retrieveColorCodedCorrelationMap(rMat,headIndices);
    makePlotWithNiceAxes(bMat,typee);
    makePlotWithNiceAxes(rMat>rPercentile,typee);
end
end

function bMat = retrieveColorCodedCorrelationMap(rMat,headIndices)
bMat = false(size(rMat,1),length(headIndices));
for i = 1:length(headIndices)
    headIndexx = headIndices{i};
    for k = headIndexx
            bMat(k,i) = true;   
    end
end
end

function makePlotWithNiceAxes(mx,typee)
h = figure();
[rows, columns, ~] = size(mx);
pcolor([mx, zeros(rows, 1); zeros(1, columns+1)]);
%axxis = caxis();
%caxis([0,axxis(2)+2])
if isa(mx,'logical')
    colormap('gray');
else
    colormap('jet');
end
%colorbar;
%caxis([0.72 1]);
%colorbar('Ticks',[min(mx(:)) 1]);

    rstrr = cell(1,length(0:0.5:rows+1));
for i = 1:length(rstrr)
    if mod(i,2)
        rstrr{1,i} = '';
    else
        rstrr{1,i} = num2str(int8(i/2));
    end

    
end
    cstrr = cell(1,length(0:0.5:columns+1));
for i = 1:length(cstrr)
    if mod(i,2)
        cstrr{1,i} = '';
    else
        cstrr{1,i} = num2str(int8(i/2));
    end

end
yticks(1:0.5:rows+1);
xticks(1:0.5:columns+1);
yticklabels(rstrr);
xticklabels(cstrr);
if rows == columns
    xlabel('Scan number');
else
    xlabel('Head number');
end
ylabel('Scan number');
title(['Matching matrix for ' typee]);
axis('square');
set(gca,'FontSize',14);

%set(h,'Position',[100 100,450,400]);
% figure();
% pcolor([rMat>0.95, zeros(rows, 1); zeros(1, columns+1)]);
% [rows, columns, ~] = size(rMat);
% colorbar();
% yticklabels(rstrr);
% xticklabels(cstrr);
% yticks(1:0.5:rows+1);
% xticks(1:0.5:columns+1);
end
