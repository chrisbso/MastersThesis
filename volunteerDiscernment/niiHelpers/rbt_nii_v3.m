%% Uses SPM to find a rigid-body-transformation for all .nii-files specified
function rbt_nii_v3(files)
    for i = 2:length(files)
       newFileName = files{i};
       newFileName = newFileName(1:end-4);
       newFileName = [newFileName '_adjusted.nii'];
       
       copyfile(files{i},newFileName);
       files{i} = newFileName;
    end
    spm_realign(files, struct('interp',5,'quality',1));
    spm_reslice(files, struct('interp',5,'mask',0,'mean',0,'which',1,'wrap',[0 0 0],'prefix','interp_'));
    %for i = 2:length(files)
    %    delete(files{i});
    %end
end %endfunction