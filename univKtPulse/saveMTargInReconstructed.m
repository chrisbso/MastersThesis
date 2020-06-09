%% Save MTarg in reconstructed.mat
function saveMTargInReconstructed(parentHeadsDir)
load('C:\Users\omgwt\Documents\GitHub\rfShimming\Datafiler\b0b1tools\helpers\Soerensen\checkCPmode\regionalB1ShimWorkspace.mat');

listing = dir(parentHeadsDir); 
dirFlags = [listing.isdir]; 
vars.AskWrite = 0;
vars.coeffs = ones(8,1);
opts = 'eB';
for i = 3:length(listing) 
    if dirFlags(i)
       cd([parentHeadsDir slsh listing(i).name]);
       MIDsListing = dir('*_dt_dream*.dat');
       for j = 1:length(MIDsListing)
            MIDs = extractBetween(MIDsListing(j).name,'MID','_dt');
            MIDs = str2num(MIDs{1});
            [~, ~, res] = acshim(MIDs, opts, vars);
            MTarg = res.MTarg;
            nname = MIDsListing(j).name;
            nname = nname(1:end-4);
            save([MIDsListing(j).folder '\' nname '\reconstructed.mat'],'MTarg','-append');
       end
       cd ..
    end
end
end