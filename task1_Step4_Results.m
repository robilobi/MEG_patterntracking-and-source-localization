%-----------------------------------------------------------------------
% This script will generate contrast windows for a desire time window.
% These are then used for statistical testing. 
%% Pipeline
% 1. SPM_convert (this script)
% 2. SPM_prepro 
% 3a. SPM_coregister -- template 
% 4. SPM_inversion 
% 5. Spm_results 
% 6. ...
%-----------------------------------------------------------------------
clear all
clc

cd('D:\PATTERN_INTERRUPT\SCRIPTS\scriptsSource');
addpath(genpath('D:\MAToolBox\spm12'));
spm('defaults', 'EEG');

path = 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\Source\Task1\';
path_new = 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\Source\Task1\Results\'; mkdir(path_new); % num2str(WOI(1)) '-' num2str(WOI(2)) '\' 
subjects = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26]; %task 1 e 2

invNum= [1];       
% WOI = [2000 2500; % interruption
%        2500 3000;
%        2723 2943]; %discovery
WOI = [2200 2500; % interruption
       2700 3000]; %discovery
FOI = [1 30];

for sub=subjects
    for W = 1:length(WOI)
        for inv = 1:length(invNum)
            spm_jobman('initcfg')
            clear matlabbatch
            matlabbatch{1}.spm.meeg.source.results.D = {[path 'mD_' num2str(sub) '.mat']};
            matlabbatch{1}.spm.meeg.source.results.val = invNum(inv) ;
            matlabbatch{1}.spm.meeg.source.results.woi = WOI;
            matlabbatch{1}.spm.meeg.source.results.foi = FOI;
            matlabbatch{1}.spm.meeg.source.results.ctype = 'evoked';
            matlabbatch{1}.spm.meeg.source.results.space = 1;
            matlabbatch{1}.spm.meeg.source.results.format = 'image';
            matlabbatch{1}.spm.meeg.source.results.smoothing = 12;
            spm_jobman('run', matlabbatch);
        end
    end
    disp(['DONE subject' num2str(sub)]);
end

% move .nii files
movefile([path '\*.nii'],path_new)