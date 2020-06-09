%% Generates (X,Y)-data for Tailored-Net (train, val or test)
% Inputs:
%   parentDir       -       the directory of heads/headXX {'D:\NN_training_data\heads'}
%   headIdxs        -       the headXXs to generate the RF data over {}.
%   params          -       help params:
%                                   params.type -> to show on waitbar {'unknown'}.
%                                   params.phaseOnly -> true if you want to do phase-only shims {true}
% Outputs:
%   X               -       set's inputs (coordinate of hot-spot)
%   Y               -       set's outputs (PTx-weights)

   
function [X,Y] = generateRFdata(parentDir,headIdxs,params)
% %% set up working and saving folders and save names
% if isempty(saveDir)
%     saveDir = 'D:\NN_training_data';
% end
% 
% if isempty(saveName) 
%     c = clock; % get the time and date
%     c = num2str(c(1:end-1)); %remove seconds
%     saveName = ['generatedRFdata_' c(~isspace(c)) '_nIter' num2str(nIter) '.mat'];
% end
% 
if isempty(parentDir)
    parentDir = 'D:\NN_training_data\heads';
end

if isempty(params)
    params.type = 'unknown';
    params.phaseOnly = true;
end

%% Find out what folder you're running this in, and load the proper workspace
% variables;
funcFold = mfilename('fullpath');
[~,funcFold] = strtok(fliplr(funcFold),slsh);
funcFold = fliplr(funcFold);

tmpp = load([funcFold 'acshimVars.mat'],'vars');
vars = tmpp.vars;
vars.GaussMask = repmat(0.05,1,3);
clear tmpp

%% Find out how many examples you get per set (decreases running time)
recFiles = getReconstructedFilesCellArr(headIdxs,parentDir);
maxIter = 0;
brainMasks = cell(0);
for ii = 1:length(recFiles)
   tmpp = load(recFiles{ii},'Mspm');
   brainMasks{ii} = tmpp.Mspm;
   maxIter = maxIter + numel(find(brainMasks{ii}));
end
clear tmpp

%% Set up the folders where you compute the RF settings
headDirs = getHeadFilesCellArr(headIdxs,parentDir);

%% Set output (coeffs) and input (coords) sizes
outputSize = 15;  %outputs for training (real and imag. parts of coeffs)
inputSize  = 3; % spatial coords

%% Initialize sets
%X = zeros(1,inputSize,1,maxIter);
%Y = zeros(maxIter,outputSize);


opts='ueB';
k = 0;
strr = ['RF data generation (' params.type ')'];
ppm = ParforProgressbar(maxIter, 'title', strr);
%h_wb = waitbar(0,'Starting data generation...');
for ii = 1:length(headDirs)
       %cd to the current head/volunteer
       cd(headDirs{ii});
       %set up MIDs
       MIDs = getMIDsForRFshim(headDirs{ii});
       [h,w,d] = ind2sub(size(brainMasks{ii}),find(brainMasks{ii}));
       parforLen = length(h);
       parX = zeros(1,inputSize,1,parforLen);
       parY = zeros(parforLen,outputSize);
       parfor j = 1:parforLen
           parVars = vars;
           %perc = floor(100*(k)/maxIter);
           %waitbar(perc/100,h_wb,sprintf('Calculating ( %s ): iter %d/%d, %d%% done...',params.type,k+1,maxIter,perc));
           parVars.GaussMCnt = [h(j) w(j) d(j)]; 
           [coeffs,~,res] = acshim(MIDs,opts,parVars);
           
           %Set up parX
           cntrCoord = res.aux.coords; %%get the GaussMCnt's  coordinates
           parX(:,:,:,j) = [cntrCoord{1}(h(j)) cntrCoord{2}(w(j)) cntrCoord{3}(d(j))];
           
           %Set up parY
           coeffs = coeffs*exp(-1i*angle(coeffs(1,1))); %phase shift to remove first coeff's imag part
           if params.phaseOnly
            coeffs = coeffs./abs(coeffs); %artifically normalize coeffs
           end
           coeffsRe = real(coeffs(:))'; %get the real parts (need all)
           coeffsIm = imag(coeffs(:))'; %get the imag parts (need all-1)
           parY(j,:) = [coeffsRe coeffsIm(2:end)];

           %increase progress
           ppm.increment();
       end
       X = cat(4,X,parX);
       Y = cat(1,Y,parY);
end

%close(h_wb);

end