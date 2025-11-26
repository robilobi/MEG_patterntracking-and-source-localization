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
sublist = [7 8 9 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
b = 2; %how many blocks to analyse 2 for task 3
%=========================== COND DEFINITION
filelist = {'DSS5_TASK3_fullepoch_Sub'};
condlists = {{'t3-REG','t3-REGREG','t3-REGRAN'}};   % condition labels
triglists = {[20 40 60]};
file = filelist{1};
condlist = condlists{1};
triglist = triglists{1};
file_out = ['AVG_' file num2str(length(sublist))];

%=========================== START
%% Load in and averaging
alldata=struct;

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
        alldata(scount,ci).avg = dat_av.avg; % average over trials
        alldata(scount,ci).rmsavg = rms(dat_av.avg(1:size(channel,1),:),1);%rms of channels over trial duration per condition
        alldata(scount,ci).time = dat_av.time;
        alldata(scount,ci).label = dat_av.label;
        alldata(scount,ci).trials = cfg.trials; % which trials were included in average
    end
    fclose('all');
end
writefile = [path file_out '.mat'];
save(writefile,'alldata');
