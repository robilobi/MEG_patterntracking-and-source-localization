%-----------------------------------------------------------------------
% Job saved on 21-Jan-2024 19:22:35 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (12.5)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
pathin = ['D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\Source\Task1\Results\'];  %if you take the nii directly
addpath(genpath('D:\MAToolBox\spm12\'))
spm eeg
f = {'1_30'};
Inv = 1;%  
type = {'GS'};
tw1 = {'2200_2500'};
tw2 = {'2200_2500'};
rsltdir=[pathin 'task1_inter_3levels_22002500'];    mkdir(rsltdir);
% tw1 = {'2700_3000'};
% tw2 = {'2700_3000'};
% rsltdir=[pathin 'task1_disc_3levels_2700_3000'];    mkdir(rsltdir);

EXP.dir_glm = rsltdir; 
EXP.dir_sum = rsltdir; 
EXP.thres.clusterInitAlpha = 0.05;
EXP.thres.extent = 100;
EXP.thres.clusterInitExtent = 100;

subjects = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 20 21 23 24 26 19 22 25]; %19 22 25
% condorder = {REG REGREG REGRAN} =  1 2 3
clear matlabbatch
spm_jobman('initcfg')
matlabbatch{1}.spm.stats.factorial_design.dir = {[rsltdir '\']};
n = 1; 
for sub = subjects
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(n).scans = {    
    [pathin 'mD_' num2str(sub) '_' num2str(Inv) '_t' tw1{1} '_f' f{1} '_1.nii,1'];    
    [pathin 'mD_' num2str(sub) '_' num2str(Inv) '_t' tw2{1} '_f' f{1} '_2.nii,1'];  
    [pathin 'mD_' num2str(sub) '_' num2str(Inv) '_t' tw2{1} '_f' f{1} '_3.nii,1']};  

matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(n).conds = [1 2 3];
n=n+1;
end
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = 1; %1 = dependent
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = 0;% 1 = unequal 
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.review.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.review.display.matrix = 1;
matlabbatch{2}.spm.stats.review.print = 1; %'pdf';

matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.con.consess{1}.fcon.name = 'ALL';
matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = [eye(3) ones(3,length(subjects))/length(subjects)];
matlabbatch{4}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.consess{2}.tcon.name = 'REG > REG1REG2 ';
matlabbatch{4}.spm.stats.con.consess{2}.tcon.weights = [1 -1 0];
matlabbatch{4}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.consess{3}.tcon.name = ' REG1REG2 > REG';
matlabbatch{4}.spm.stats.con.consess{3}.tcon.weights = [-1 1 0];
matlabbatch{4}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.consess{4}.tcon.name = ' REG1REG2 > RAN';
matlabbatch{4}.spm.stats.con.consess{4}.tcon.weights = [0 1 -1];
matlabbatch{4}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.consess{5}.tcon.name = 'RAN > REG1REG2';
matlabbatch{4}.spm.stats.con.consess{5}.tcon.weights = [0 -1 1];
matlabbatch{4}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.consess{6}.tcon.name = 'REG > RAN';
matlabbatch{4}.spm.stats.con.consess{6}.tcon.weights = [1 0 -1];
matlabbatch{4}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.delete = 0;

matlabbatch{5}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{5}.spm.stats.results.conspec.titlestr = '';
matlabbatch{5}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{5}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{5}.spm.stats.results.conspec.thresh = 0.05;
matlabbatch{5}.spm.stats.results.conspec.extent = 100;
matlabbatch{5}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{5}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{5}.spm.stats.results.units = 1;
matlabbatch{5}.spm.stats.results.export{1}.ps = true;

spm_jobman('run',matlabbatch);
graficname = [rsltdir 'anova.pdf'];
spm_print(graficname, '', 'pdf')
EXP = myspm_result_new(EXP);

cd('D:\PATTERN_INTERRUPT\SCRIPTS\scriptsSource\');

