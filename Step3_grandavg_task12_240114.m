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
file = filelist{task};

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
    
    
    CS = [dirloc 'SelectedChannelsS' num2str(s) '.mat'];
    load(CS);
    megChan = ft_channelselection('all', channel(1:40));
    cfg=[];
    cfg.channel= megChan;
    cfg.keepchannel = 'no';
    data=ft_preprocessing(cfg,data);
    
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
        tasks(t).alldata(scount,ci).avg = dat_av.avg; % average over trials
        tasks(t).alldata(scount,ci).rmsavg = rms(dat_av.avg(1:size(channel,1),:),1);%rms of channels over trial duration per condition
        tasks(t).alldata(scount,ci).time = dat_av.time;
        tasks(t).alldata(scount,ci).label = dat_av.label;
        tasks(t).alldata(scount,ci).trials = cfg.trials; % which trials were included in average
    end
    fclose('all');
    end
end
alldata = [];
file_out = ['AVG_DSS5_TASK1_S' num2str(length(sublist))];
writefile = [path file_out '.mat'];
alldata = tasks(1).alldata;
save(writefile,'alldata'); 
alldata = [];
file_out = ['AVG_DSS5_TASK2_S' num2str(length(sublist))];
writefile = [path file_out '.mat'];
alldata = tasks(2).alldata;
save(writefile,'alldata'); 
