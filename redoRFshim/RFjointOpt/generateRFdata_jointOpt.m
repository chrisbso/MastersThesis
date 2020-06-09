%% Generate the data for RF-UP-Net
function [X_joint,Y_joint] = generateRFdata_jointOpt(parentDir,saveDir,saveName,nIter,trainIdxs)
if isempty(saveDir)
    saveDir = 'D:\NN_training_data';
end

if isempty(saveName) 
    c = clock; % get the time and date
    c = num2str(c(1:end-1)); %remove seconds
    saveName = ['generatedRFdata_jointOpt' c(~isspace(c)) '_nIter' num2str(nIter) '.mat'];
end

if isempty(parentDir)
    parentDir = 'D:\NN_training_data\heads';
end

%% Find out what folder you're running this in, and load the proper workspace variables;
funcFold = mfilename('fullpath');
[~,funcFold] = strtok(fliplr(funcFold),slsh);
funcFold = fliplr(funcFold);

load([funcFold 'RFjointOpt_workspace.mat'],'vars');
vars.verbose = 0;
%% 
numelOut = 15; %outputs for training (real and imag. parts of coeffs)
numelIn = 4; %inputs for training (xyz and drop-off of hotspot)

% set up an arbitrary MID to get things started
files = getHeadFilesCellArr(trainIdxs,parentDir);
cd(files{1});
MIDs = getMIDsForRFshim(files{1});

files = getReconstructedFilesCellArr(trainIdxs,parentDir); %get the reconst. file names

load(files{1},'aux'); %to get some nessesary data
hheight = length(aux.coords{1}); %
wwidth = length(aux.coords{2});
FOV     = aux.FOV; %transv. FOV is not correct
FOV(3)  = 210; % a small cheat, the max FOV of all the data 
FOV     = 0.72*FOV/1e3; % in meters

X_joint = zeros(1,numelIn,1,nIter);
Y_joint = zeros(length(trainIdxs),numelOut);


vars.catB1p = zeros(hheight,wwidth,0,8);
vars.catMTarg = zeros(hheight,wwidth,0);


rCoords = [-FOV(1)/2+rand(nIter,1)*FOV(1), -FOV(2)/2+rand(nIter,1)*FOV(2), -FOV(3)/2+rand(nIter,1)*FOV(3)];
GaussSig = repmat((0.01 + 0.03*rand(nIter,1)),1,3); %random (spherical) drop-off

save([saveDir slsh saveName],'X_joint','Y_joint','-v7.3');
opts = 'ueBZ';
%%Set up the b1p's
for i = 1:length(files)
            tmp = load(files{i},'b1p_kt'); %%this "_kt"-part already done the weird phase-shifting
            vars.catB1p = cat(3,vars.catB1p,tmp.b1p_kt);
end        
      
%hh = waitbar(0,'(JO DATA GEN) Starting data generation');
WaitMessage = parfor_wait(sum(nIter), 'Waitbar', true);
parfor j = 1:nIter
varss = vars;
varss.catMTarg = zeros(hheight,wwidth,0);
posn = zeros(1,3);
rrCoords = rCoords(j,:);
gGaussSig = GaussSig(j,:);
for i = 1:length(files)
        tmp = load(files{i},'aux','Mspm');
        
        %get vox coords of center of blob
        [~,posn(1)] = min(abs(tmp.aux.coords{1}-rrCoords(1)));
        [~,posn(2)] = min(abs(tmp.aux.coords{2}-rrCoords(2)));
        [~,posn(3)] = min(abs(tmp.aux.coords{3}-rrCoords(3)));
        
        newMTarg = (tmp.Mspm).*gaussianmask(tmp.Mspm,tmp.aux,posn,gGaussSig);
        varss.catMTarg = cat(3,varss.catMTarg,newMTarg);
       
end
        %figure();
        %pcolor(fliplr(rot90(rot90(rot90(((squeeze(newMTarg(:,:,6)))))))));
    [coeffs,~,~] = acshim(MIDs,opts,varss);
    X_joint(1,:,1,j) = [rrCoords gGaussSig(1)];
    Y_joint(j,:) = [real(coeffs)' imag(coeffs(2:end))'];
    %ppm.increment();
    WaitMessage.Send;
    %perc = floor(100*j/nIter);
    %disp(perc);
    %waitbar(perc/100,hh,sprintf('(JO DATA GEN) Generating: Iter %d/%d, %d%% done...',j,nIter,perc));
    %if ~mod(j,1000)
    %    save([saveDir slsh saveName],'XTrain','YTrain','-append');
    %    fprintf('Successfully saved after %d iterations\n',j);
    %end
end
WaitMessage.Destroy;
save([saveDir slsh saveName],'X_joint','Y_joint','-append');
fprintf('Successfully saved\n');
%close(hh);
%delete(ppm);
end