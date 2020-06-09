%% This function is not yet done, and is currently just rubbish.
function [raMagn] = rbt_nii(refMagn, refAux, sourceMagn, sourceAux, filepath, vars)

if nargin < 4
    error('need at least 2 input argument!')
end
if nargin < 4 || isempty(filepath)
    filepath='./';
end
if nargin < 5 || isempty(vars)
    vars=struct();
end
if ~isfield(vars,'mt') || isempty(vars.mt)
    vars.mt = 0.05;
end

refI = zeros(1,3);
sourceI = zeros(1,3);
for ii=1:3
    if mod(ii,2)
	[~,refI(ii)]=min(abs(refAux.coords{ii}(end:-1:1)));
	[~,sourceI(ii)]=min(abs(sourceAux.coords{ii}(end:-1:1)));
    else
        [~,refI(ii)]=min(abs(refAux.coords{ii}));
        [~,sourceI(ii)]=min(abs(sourceAux.coords{ii}));
    end
end

nii = make_nii(refMagn, refAux.Res, refI);
save_nii(nii, [filepath 'refMagn.nii']);

nii = make_nii(refMagn, sourceAux.Res, sourceI);
save_nii(nii, [filepath 'sourceMagn.nii']);

vrefMagn = spm_vol( [filepath 'refMagn.nii']);
vsourceMagn = spm_vol( [filepath 'sourceMagn.nii']);

    x = spm_coreg(vrefMagn, vsourceMagn, struct('cost_fun','ncc' ) );
    M = spm_matrix(x);

    spm_reslice(files, struct('interp',5,'mask',0,'mean',0,'which',1,'wrap',wrapopt));
end %endfunction
