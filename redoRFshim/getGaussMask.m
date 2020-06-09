function M = getGaussMask(Mspm,aux,GaussMCnt,GaussSig)
%Careful, GaussMCnt is COORDINATE (not index!)
        [~,posn(1)] = min(abs(aux.coords{1}-GaussMCnt(1)));
        [~,posn(2)] = min(abs(aux.coords{2}-GaussMCnt(2)));
        [~,posn(3)] = min(abs(aux.coords{3}-GaussMCnt(3)));
        
        M = (Mspm).*gaussianmask(Mspm,aux,posn,GaussSig);
end