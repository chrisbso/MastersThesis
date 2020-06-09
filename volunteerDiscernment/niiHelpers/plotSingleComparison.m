function plotSingleComparison(rVec,rPercentile)
x = 1:length(files);
abovePercentile = rVec(rVec>=rPercentile);
xAbove = x(rVec>=rPercentile);
belowPercentile = rVec(rVec<rPercentile);
xBelow = x(rVec<rPercentile);

if boolPlot
    figure();
    hold on;
    plot(xAbove,abovePercentile,'*g','MarkerSize',12);
    plot(xBelow,belowPercentile,'.','MarkerSize',12);
    line(xlim,[rPercentile rPercentile]);
    for i = 1:length(xAbove)
       line([xAbove(i) xAbove(i)],[min(rVec)*0.9,abovePercentile(i)],'LineStyle','--'); 
    end
    xticks(x);
end
end
