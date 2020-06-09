%% NOT WORKING (RUBBISH). See v3 (CBS 200130)
function rbt_nii_v2(files)
    spmVols = cell(length(files),1);
    spmVols{1} = spm_vol(files{1}); %reference image to coregister to
    spmMat = cell(length(files)-1,1);
    for i = 2:length(files)
       spmVols{i} = spm_vol(files{i}); 
       spmMat{i-1} = spm_matrix(spm_coreg(spmVols{i},spmVols{1}, struct('cost_fun','ncc' )));
       
       newFileName = files{i};
       newFileName = newFileName(1:end-4);
       newFileName = [newFileName '_adjusted.nii'];
       
       copyfile(files{i},newFileName);
       files{i} = newFileName;
       spm_get_space(files{i}, spmMat{i-1}*spmVols{i}.mat)
    end
    spm_reslice(files, struct('interp',5,'mask',0,'mean',0,'which',1,'wrap',[0 0 0],'prefix','interp_'));
    %for i = 2:length(files)
    %    delete(files{i});
    %end
end %endfunction