%% Help function, s.t. using unix or windows, call "slsh()" to get the correct slash for file-specifications
function char = slsh()
    if isunix
        char = '/';
    else
        char = '\';
    end
end