function [nnData,idxs] = generateRFdata(parentDir,saveDir,saveName,nIter,genIdxs)
if isempty(saveDir)
    saveDir = 'D:\NN_training_data';
end

if isempty(saveName) 
    c = clock; % get the time and date
    c = num2str(c(1:end-1)); %remove seconds
    saveName = ['generatedRFdata_' c(~isspace(c)) '_nIter' num2str(nIter) '.mat'];
end

if isempty(parentDir)
    parentDir = 'D:\NN_training_data\heads';
end
listing = dir(parentDir); 
dirFlags = [listing.isdir];

if nargin > 4
    nnData = cell(length(genIdxs),1);
    dataSet = cell(nIter,4);
    idxs = cell(length(genIdxs),1);
else
    nnData = cell(sum(dirFlags(:))-2,1);
    dataSet = cell(nIter,4);
    idxs = cell(sum(dirFlags(:))-2,1);
end

%% Find out what folder you're running this in, and load the proper workspace variables;
funcFold = mfilename('fullpath');
[~,funcFold] = strtok(fliplr(funcFold),slsh);
funcFold = fliplr(funcFold);

load([funcFold 'generateRFdataWorkspace.mat'],'vars');
vars.verbose = 0;
%% 

opts='ueB';
k = 0;
maxIter = nIter*length(nnData);
WaitMessage = parfor_wait(maxIter,'Waitbar',true);
%h = waitbar(0,'Starting data generation');
save([saveDir slsh saveName],'idxs','nnData','-v7.3');
for i = 3:length(listing)
    if dirFlags(i)
       if nargin > 4
           foundHead = false;
          for j = 1:length(genIdxs)
            if strcmp(['head' num2str(genIdxs(j))],listing(i).name)
                foundHead = true;
                break;
            end
          end
          if ~foundHead
            continue;
          end
       end
       cd([parentDir slsh listing(i).name]);
       MIDsListing = dir('*_dt_dream*.dat');
       if length(MIDsListing) ~= 1
           error(['Found several DREAM-files in one folder. Check ' listing(i).name '.\n'])
       else
           MIDsName = MIDsListing(1).name;
           tmpp = load([strtok(MIDsName,'.') slsh 'reconstructed.mat'],'aux','Mspm');
           MIDs = extractBetween(MIDsName,'MID','_dt');
           MIDs = str2num(MIDs{1});
           parfor n = 1:nIter
            [coords,dropOff,coeffsReal,coeffsIm] = generateMaskTrainingForScan(MIDs, opts, vars, tmpp.aux.FOV,tmpp.aux.coords);
%             dataSet{n,1} = coords;
%             dataSet{n,2} = dropOff;
%             dataSet{n,3} = coeffsReal;
%             dataSet{n,4} = coeffsIm;
            dataSet(n,:) = {coords,dropOff,coeffsReal,coeffsIm};
            WaitMessage.Send;
            %perc = floor(100*(nIter*k+n)/(maxIter));
            %waitbar(perc/100,h,sprintf('Generating: scan %d/%d, iter %d/%d, %d%% done...',k+1,length(nnData),n,nIter,perc));
           end
           %perc = floor(100*(k+1)/length(3:length(listing)));
           %waitbar(perc/100,h,sprintf('Generating: scan %d/%d, %d%% done...',k+1,length(3:length(listing)),perc));
       end
       k = k+1;
       if nargin > 4
          nnData{k} = dataSet;
       else
        idx = strtok(fliplr(listing(i).name),'d');
        idx = str2num(fliplr(idx));
        nnData{idx} = dataSet;
       end
       idxs{k} = listing(i).name;
       save([saveDir slsh saveName],'idxs','nnData','-append');
       fprintf('Saved %s.\n',idxs{k});
    end
    
end
%close(h);
WaitMessage.Destroy;
end

