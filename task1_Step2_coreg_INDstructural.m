%%%%%
%% Coregister with individual MRI scans or template
% Roberta Bianco 11/2019
%%
clc
clear
cd('D:\PATTERN_INTERRUPT\SCRIPTS\scriptsSource\')
addpath(genpath('D:\MAToolBox\spm12\'))
%% run up spm
%spm eeg;
indir = 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\Source\Task1\'; 
subjects = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26]; %task 1 e 2

InvNum = 1;  %which inversion number
meshres = 2; % 1 = cortex_5124 surface mesh, 2 = cortex_8196, 3 = cortex_20484
comment = 'canonical';

for s = subjects
    disp(['loading subject_' num2str(s)]);    
    spm_jobman('initcfg')
    clear matlabbatch;
    matlabbatch{1}.spm.meeg.source.headmodel.D = {[indir 'mD_' num2str(s) '.mat']};
    matlabbatch{1}.spm.meeg.source.headmodel.val = InvNum;
    matlabbatch{1}.spm.meeg.source.headmodel.comment = comment;
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.template = 1;
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = meshres;  %1 = cortex_5124 surface mesh, 2 = cortex_8196, 3 = cortex_20484
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'FIL_CTF_L';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'FIL_CTF_R';
    
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
    matlabbatch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
    matlabbatch{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';
    spm_jobman('run',matlabbatch);
    
    %       graficname = [indir 'forwardmod_S_' num2str(subjects(s)) '.pdf'];
    %       spm_print(graficname, '', 'pdf')
end