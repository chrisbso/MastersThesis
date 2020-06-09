%% Predict the time-varying weights using net given the target (RF-amp. map)
function predKT8 = predictAndConstruct8Ktp(net,target)
    tmp = predict(net,target);
    predKT8 = zeros(8,8,size(tmp,1));
    for i = 1:size(tmp,1)
        cRe = reshape(tmp(i,1:64),8,8);
        cIm = reshape([0 tmp(i,65:end)],8,8);
        predKT8(:,:,i) = cRe + 1i*cIm;
    end
end