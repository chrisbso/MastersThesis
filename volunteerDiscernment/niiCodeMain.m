load('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\b0b1tools\helpers\Soerensen\niiCode\niiHelpers\filenamesForTestHEAD.mat')
rPercentile = 0.95;
maskThreshold = 0.0001;
%
headIndicesB0 = headDiscernment(justHeadFilesB0,rPercentile,maskThreshold,'3DEGRE',true);
headIndicesB1 = headDiscernment(justHeadFilesB1,rPercentile,maskThreshold,'DREAM',true);
%
%winopen(justHeadFilesB1{2})
%winopen(justHeadFilesB1{1})
%winopen(justHeadFilesB0{2})
%winopen(justHeadFilesB0{1})