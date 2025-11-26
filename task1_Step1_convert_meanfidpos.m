%% Convert FT2SPM
%
% Roberta Bianco 2021
% This first step in the SPM pipeline. It follows the first two
% preprocessing steps in fieldtrip: define trial and visual rejection.

% SPM pipeline is henceforth:
% 1. SPM_convert (this script)
% 2. sort conditions
% 3. take mean fiducial positions from all blocks
% 4. average by condition


%% setup
clearvars; close all; clear all;
addpath('D:\MAToolBox\fieldtrip-20171128');
addpath(genpath('D:\MAToolBox\spm12'));
addpath('D:\MAToolBox\fieldtrip-20171128\utilities');
addpath('D:\MAToolBox\fieldtrip-20171128\fileio');
addpath('D:\MAToolBox\fieldtrip-20171128\forward');
%=========================== PATH
path_in = 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\';
raw_data = 'D:\PATTERN_INTERRUPT\DATA\';
getsubstr

%%%%%%%%%%% TASK1
path_out = 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\Source\Task1\'; mkdir(path_out); %%
condlist = {'t1-REG','t1-REGREG','t1-REGRAN'};   % condition labels
file_in = 'DSS5_TASK1-2_fullepoch_Sub';
sublist = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26]; %task 1 e 2
triglist = [70 90 110];
%%%%%%%%%%%
%=========================== VAR SETTINGS
%=========================== START
%% Load in and averaging
% for k = comp  %%Uncomment to loop through DSS and change path
for s = sublist
    
    load([path_in file_in num2str(s) '.mat']); %Full
    
    cfg = [];cfg.trials = ismember(data.trialinfo(:,1), triglist);
    datatask = ft_selectdata(cfg, data);
    
    cfg = [];
    cfg.resamplefs = 200;
    datares = ft_resampledata(cfg, datatask);
    
    writefile = [path_out 'D_' num2str(s) '.mat'];
    D = spm_eeg_ft2spm(datares,  writefile); %run conversion from fieldtrip to spm
    load(writefile);
    
    %% add and sort condition labels to each trial
    D.condlist = condlist;
    conds = containers.Map(triglist,condlist); % dictionary from triglist to condlist
    for i = 1:length(datares.trialinfo)
        D.trials(i).label = datares.trialinfo(i);     % add trial info, sample info and condition labels
        % D.trials(i).onset = data.sampleinfo(i, 1);
        D.trials(i).label = conds(D.trials(i).label);
    end
    save(writefile,'D');
    
    %% sort conditions
    S=[];
    S.D = [path_out 'D_' num2str(s) '.mat'];
    S.condlist = condlist;
    S.save = 1;
    D = spm_eeg_sort_conditions(S);
    save(D);
    
    %% compute fiducial mean position across blocks
    average_headshape = [];
    nblocks = substr{3,s};
    for ind = 1:nblocks
        dataset = [raw_data 'Subject' num2str(s) '\' sprintf(substr{1,s},ind) '.ds'];
        headshape = ft_read_headshape(fullfile(dataset));
        if ind == 1
            average_headshape.fid.pos = headshape.fid.pos;
        else
            average_headshape.fid.pos = average_headshape.fid.pos + headshape.fid.pos;
        end
    end
    
    average_headshape.fid.pos = average_headshape.fid.pos/nblocks;
    average_headshape.pos = headshape.pos;
    average_headshape.fid.label = headshape.fid.label;
    average_headshape.coordsys = headshape.coordsys;
    average_headshape.unit = headshape.unit ;
    
    %% add mean fiducial position information to averaged data
    dataset = [raw_data 'Subject' num2str(s) '\' sprintf(substr{1,s},2) '.ds'];
    D = sensors(D, 'MEG', ft_convert_units(ft_read_sens(fullfile(dataset)), 'mm'));
    D = fiducials(D, ft_convert_units(average_headshape, 'mm'));  % add fiducial and sensor information from raw data
    save(D);
    
    %% project scalp map
    spm_jobman('initcfg')
    matlabbatch{1}.spm.meeg.preproc.prepare.D = {[path_out 'D_' num2str(s) '.mat']};
    matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadtemplate = {'D:\MAToolBox\spm12\EEGtemplates\CTF275_setup.mat'};
    matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.project3dMEG = 1;
    spm_jobman('run', matlabbatch);
    
    %% add unit to MEG data
    D(D.indchantype('MEG'), :, :) = 1e15*D(D.indchantype('MEG'), :, :);
    D = D.units(['MEG'], 'T');
    save(D);
    
    %     %baseline correct and average
    %     S=[];
    %     S.D = [path_out 'D_' num2str(s) '.mat'];
    %     S.timewin = [1.5 2]; % tw before change
    %     dD = spm_eeg_bc(S);
    %
    %average
    S=[];
    S.D = [path_out 'D_' num2str(s) '.mat'];
    aD =spm_eeg_average(S);
    
end



