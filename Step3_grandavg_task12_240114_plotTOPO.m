%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Roberta Bianco 03/2021
% Average across trials per condition each subject data
% - Load dssed subject data
% - select auditory channels
% - compute mean over trials per condition for each subject data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% setup
rehash toolboxcache
restoredefaultpath
addpath('D:\MAToolBox\fieldtrip-20171128');
addpath('D:\MAToolBox\NoiseTools');
ft_defaults;
clear all;

%=========================== PATH
cd('D:\PATTERN_INTERRUPT\SCRIPTS\');
path= 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\';
dirloc= 'D:\PATTERN_INTERRUPT\RESULTS\Step0_Selectchannels\';
cd('D:\PATTERN_INTERRUPT\SCRIPTS\');
%=========================== VAR SETTINGS
sublist = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
% prompt = 'How many blocks to include? (if X, it takes the last X blocks of this task)';
b = 3; % include last 3 blocks for task 1 and 2 , last 2 for task 3
%=========================== COND DEFINITION
filelist = {'DSS5_TASK1-2_fullepoch_Sub'};
condlists = {{'t1-REG','t1-REGREG','t1-REGRAN', 't2-REG','t2-REGREG','t2-REGRAN'}};   % condition labels
triglists = [70 90 110 10 30 50];
file = filelist{1};

%=========================== START
%% Load in and averaging
scount = 0;
for s = sublist
    scount = scount+1;
    display(['SUBJECT' num2str(s)]);
    load([path file num2str(s) '.mat']); %baseline ONSET
    
    %% baseline correct
    cfg = [];
    cfg.demean = 'yes';
    cfg.baselinewindow = [-0.5 0];
    data = ft_preprocessing(cfg, data);
    
    
    %% split by task
    cfg = [];
    cfg.trials = ismember(data.trialinfo(:,1), triglists(1:3)); % finding trials per condition
    task1 = ft_selectdata(cfg, data);
    cfg = [];
    cfg.trials = ismember(data.trialinfo(:,1) , triglists(4:6)); % finding trials per condition
    task2 = ft_selectdata(cfg, data);
    
    for t =1:2
        if t == 1
            data = task1;
            triglist = [70 90 110];
            condlist = {'t1-REG','t1-REGREG','t1-REGRAN'};
        else
            data = task2;
            triglist = [10 30 50];
            condlist = {'t2-REG','t2-REGREG','t2-REGRAN'};
        end
        %% find blocks to include
        actualblocks = unique(data.trialinfo(:,3));
        if b > length(actualblocks) %for those data where less blocks were recorded
            includeblocks = actualblocks;
        else
            includeblocks = actualblocks(end-(b-1):end);
        end
        
        
        %% average by condition
        cfg = [];
        for ci = 1:length(condlist)
            cfg.trials = find((data.trialinfo(:,1) == triglist(ci) & ismember(data.trialinfo(:,3), includeblocks))); % finding trials per condition
            cfg.removemean='no';
            dat_av = ft_timelockanalysis(cfg,data);
            tasks(t).alldata{scount,ci} = dat_av;
        end
        
    end
end


%% plot topo TASK1

reg =    tasks(1).alldata(:,1);
regreg=  tasks(1).alldata(:,2);
regran=  tasks(1).alldata(:,3);

cfg = [];
cfg.channel = 'all';
cfg.latency = 'all';
cfg.parameter = 'avg';
grandavg_reg = ft_timelockgrandaverage(cfg, reg{:});
grandavg_regreg = ft_timelockgrandaverage(cfg, regreg{:});
grandavg_regran = ft_timelockgrandaverage(cfg, regran{:});

% cfg = [];
% cfg.operation = 'subtract';
% cfg.parameter = 'avg';
% difference= ft_math(cfg,  grandavg_regreg,grandavg_reg);

figure; % Interruption
cfg = [];
cfg.layout='CTF274_FIL_lay';
cfg.xlim=[2.2 2.5];
cfg.zlim = [-10e-14 10e-14];
cfg.marker = 'off';
cfg.highlight='off';
cfg.comment = 'off';
cfg.colorbar = 'SouthOutside';
subplot(1,2,1);
ft_topoplotER(cfg, grandavg_reg );
subplot(1,2,2);
ft_topoplotER(cfg,grandavg_regreg );
title([' REG and REGREG, TW ' num2str( cfg.xlim) ' task1']);
filename=([path 'Plots_final\TOPO_TASK1_REG&REGREG']);
print([filename '.pdf'],'-dpdf','-bestfit');


% cfg = [];
% cfg.operation = 'subtract';
% cfg.parameter = 'avg';
% difference= ft_math(cfg,  grandavg_regreg,grandavg_regran);

figure;
cfg = [];
cfg.layout='CTF274_FIL_lay';
cfg.xlim=[2.7 3];
cfg.zlim = [-10e-14 10e-14];
cfg.marker = 'off';
cfg.highlight='off';
cfg.comment = 'off';
cfg.colorbar = 'SouthOutside';
subplot(1,2,1);
ft_topoplotER(cfg, grandavg_regreg );
subplot(1,2,2);
ft_topoplotER(cfg,grandavg_regran );
title([' REGREG & regran, TW ' num2str( cfg.xlim) ' task1']);
filename=([path 'Plots_final\TOPO_TASK1_REGREG&RAN']);
print([filename '.pdf'],'-dpdf','-bestfit');



%% plot topo TASK2

reg =    tasks(2).alldata(:,1);
regreg=  tasks(2).alldata(:,2);
regran=  tasks(2).alldata(:,3);

cfg = [];
cfg.channel = 'all';
cfg.latency = 'all';
cfg.parameter = 'avg';
grandavg_reg = ft_timelockgrandaverage(cfg, reg{:});
grandavg_regreg = ft_timelockgrandaverage(cfg, regreg{:});
grandavg_regran = ft_timelockgrandaverage(cfg, regran{:});


figure;
cfg = [];
cfg.layout='CTF274_FIL_lay';
cfg.xlim=[0.7 1];
cfg.zlim = [-1e-13 1e-13];
cfg.marker = 'off';
cfg.highlight='off';
cfg.comment = 'off';
cfg.colorbar = 'SouthOutside';
ft_topoplotER(cfg, grandavg_regreg);
title([' REGREG, TW ' num2str( cfg.xlim) ' task2']);
filename=([path 'Plots_final\TOPO_TASK2_regxnovel']);
print([filename '.pdf'],'-dpdf','-bestfit');


figure;
cfg = [];
cfg.layout='CTF274_FIL_lay';
cfg.xlim=[2.9 3.2];
cfg.zlim = [-1e-13 1e-13];
cfg.marker = 'off';
cfg.highlight='off';
cfg.comment = 'off';
cfg.colorbar = 'SouthOutside';
ft_topoplotER(cfg, grandavg_regreg);
title([' REGREG, TW ' num2str( cfg.xlim) ' task2']);
filename=([path 'Plots_final\TOPO_TASK2_regxresume']);
print([filename '.pdf'],'-dpdf','-bestfit');


cfg         = [];
cfg.latency = [0.7 1];
regnovel = ft_selectdata(cfg,grandavg_regreg);
cfg         = [];
cfg.latency = [2.9 3.2];
regresume = ft_selectdata(cfg,grandavg_regreg);
regresume.time = regnovel.time;
cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
difference= ft_math(cfg,  regnovel,regresume);

figure;
cfg = [];
cfg.layout='CTF274_FIL_lay';
cfg.xlim=[0.7 1];
cfg.zlim = [-2e-14 2e-14];
cfg.marker = 'off';
cfg.highlight='off';
cfg.comment = 'off';
cfg.colorbar = 'SouthOutside';
ft_topoplotER(cfg, difference);
title([' REGREG, TW ' num2str( cfg.xlim) ' task2']);
filename=([path 'Plots_final\TOPO_TASK2_regxnovel-resume']);
print([filename '.pdf'],'-dpdf','-bestfit');
