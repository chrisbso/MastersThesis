nPairs = input('Specify number of rf<->map-pairs you want to generate: ');
vars.AskWrite = 0;
mapSize = size(res.MTarg);
coeffsReal = zeros(nPairs,8); % ch 8,1,2,...,7
coeffsIm = zeros(nPairs,7); %only 7, only _relative_ phase (ch. 8 always 0-phased)
mapSet = ones(mapSize(1),mapSize(2),mapSize(3),1,nPairs);
for j = 1:nPairs
    vars.GaussMCnt = floor([rand()*(mapSize(1)+1) rand()*(mapSize(2)+1) rand()*(mapSize(3)+1)]);
    vars.GaussMask = [(0.01 + 0.14*rand()) (0.01 + 0.14*rand()) (0.01 + 0.14*rand())];
    [coeffs,fitn,res] = acshim(MIDs,opts,vars);
    mapSet(:,:,:,1,j) = res.MTarg;
    coeffsReal(j,:) = real(coeffs);
    coeffsIm(j,:) = imag(coeffs(2:end));
    fprintf(['\n Iter:' num2str(j) '\n']);
end

