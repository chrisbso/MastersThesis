%vars.GaussMask = [0.05 0.05 0.05];
%[coeffs,fitn,res] = acshim(MIDs,opts,vars);
if ~exist('net','var')
   error('Load a trained network first!'); 
end
clearvars -except net
close all;
addpath(genpath('C:\Users\omgwt\Documents\GitHub\rfShimming'))
cd C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\
regional_b1shim;
rmpath(genpath('C:\Users\omgwt\Documents\GitHub\rfShimming'))
cd C:\Users\omgwt\Documents\GitHub
addpath('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler');
vars.coeffs = predictAndConstructRFSetting(net,double(res.MTarg));
rmpath('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler');
addpath(genpath('C:\Users\omgwt\Documents\GitHub\rfShimming'))
cd C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\
[coeffs,fitn,res] = acshim(MIDs,'meB',vars);
figure;

imagesc(res.MTarg(:,:,7))
title(['vars.GaussMask = [' num2str(vars.GaussMask) ']']);
colorbar;