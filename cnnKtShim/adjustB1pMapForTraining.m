%% Adjust the RF-amplitude maps before putting the into the CNN.
% Done by adding slices on the bottom and top until nVoxTransv slices are
% reached in the transversal dir.
function trainB1p = adjustB1pMapForTraining(b1p,nVoxTransv)
%if the map already has desired size, just return it.
if size(b1p,3) == nVoxTransv
    trainB1p = b1p;
    return
end

%find how much you should put on to and bottom
diffSize = (nVoxTransv - size(b1p,3))/2;
restt = diffSize - floor(diffSize); %if the is an odd amount of slice differences in the tranvs. dir.

%setup the slices to stack
slicesToStack = zeros([size(b1p,1,2) floor(diffSize)]);
trainB1p = cat(3,slicesToStack,b1p,slicesToStack);%stack them

if restt~=0 %if slice difference is odd, just add a slice on top.
   trainB1p = cat(3,slicesToStack(:,:,1),trainB1p); 
end


end