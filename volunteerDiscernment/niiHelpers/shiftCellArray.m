%% Shift a cell arrray by one element, putting the top to the bottom and pushing everything upwards.

function shifted = shiftCellArray(cAr)
    shifted = cell(size(cAr));
    shifted(1:end-1)   = cAr(2:end);
    shifted(end)       = cAr(1);
end