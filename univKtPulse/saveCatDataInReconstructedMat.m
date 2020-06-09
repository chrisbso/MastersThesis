%% Save the concatentated data in reconstructed.mat
function saveCatDataInReconstructedMat(parentHeadsDir)
workspaceFile = mfilename('fullpath');
strr = mfilename;
workspaceFile = replace(workspaceFile,strr,'saveB0Interp_Workspace.mat');
load(workspaceFile);
%load('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\b0b1tools\helpers\Soerensen\univPulse\saveB0Interp_Workspace.mat');

listing = dir(parentHeadsDir); 
dirFlags = [listing.isdir]; 
opts = 'BqG';
for i = 3:length(listing) 
    if dirFlags(i)
       cd([parentHeadsDir slsh listing(i).name]);
       b1MIDsListing = dir('*_dt_dream*.dat');
       b0MIDsListing = dir('*_dt_fieldm*.dat');
       for j = 1:length(b1MIDsListing)
            MIDs = [extractBetween(b1MIDsListing(j).name,'MID','_dt'),...
               extractBetween(b0MIDsListing(j).name,'MID','_dt')];
            MIDs = [str2num(MIDs{1}),str2num(MIDs{2})];
            [~, ~, res] = ktshim(MIDs, opts, vars);
            meshGridCoords = res.meshGridCoords;
            b0Interp = res.b0Interp;
            MTarg_kt = res.MTarg_kt;
            smallerVOIs = res.smallerVOIs;
            b1p_kt = res.b1p_kt;
            nname = b1MIDsListing(j).name;
            nname = nname(1:end-4);
            save([b1MIDsListing(j).folder '\' nname '\reconstructed.mat'],'b0Interp','MTarg_kt','b1p_kt','meshGridCoords','smallerVOIs','-append');
       end
       cd ..
    end
end
end