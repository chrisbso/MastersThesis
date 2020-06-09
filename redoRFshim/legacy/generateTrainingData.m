nPairs = input('Specify number of rf<->map-pairs you want to generate: ');
vars.AskWrite = 0;
mapSize = size(res.shimmed);
coeffsReal = zeros(8,nPairs); % ch 8,1,2,...,7
coeffsIm = zeros(7,nPairs); %only 7, only _relative_ phase (ch. 8 always 0-phased)
mapSet = ones(mapSize(1),mapSize(2),mapSize(3),1,nPairs);
for j = 1:nPairs
    vars.coeffs = (rand(8,1).*exp(i*2*pi*rand(8,1)));
    vars.coeffs = vars.coeffs/max(abs(vars.coeffs));
    [fullCoeffs,fitn,res] = acshim(MIDs,'eB',vars);
    mapSet(:,:,:,1,j) = abs(res.shimmedTpV);
    coeffsReal(:,j) = real(fullCoeffs);
    coeffsIm(:,j) = imag(fullCoeffs(2:end));
    fprintf(['\n Iter:' num2str(j) '\n']);
end

coeffsReal = coeffsReal';
coeffsIm = coeffsIm';