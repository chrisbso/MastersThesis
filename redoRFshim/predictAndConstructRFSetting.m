%% Predict and construct the RF-weights from net given the target (blob location and drop-off)
function predRF = predictAndConstructRFSetting(net,target)
    predRF  = predict(net,target);
    predRF = predRF(1:8) - 1i*[0 predRF(9:15)];
    predRF = predRF'/max(abs(predRF));
end
