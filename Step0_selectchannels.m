%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Roberta Bianco 03/2021
% Load and prepocess MEG data
% - Load session by session
% - (Filter power line noise 50Hz out)
% - Cut in epochs
% - merge sessions into different tasks based on triggers found
% - remove outlier trials
% - plot N1 (based on auditory channelsof there is a localiser)
% RUN in DEBUG mode: plot the first 150 ms first, check the p50 or n1 and
% adjust the time window that best captures the oinset response
% - tws =  possible time windows to N1 or P50 adjusted to single subject plots
% - twsubj = index 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MANUAL SELECTION SUb 2,9,15, 20 (waek right clusters)
rehash toolboxcache
restoredefaultpath
addpath('D:\MAToolBox\fieldtrip-20171128');
addpath('D:\MAToolBox\NoiseTools');
ft_defaults;
clearvars; close all

%% Definine Settings
dir_out = 'D:\PATTERN_INTERRUPT\RESULTS\Step0_Selectchannels\'; mkdir(dir_out);
condlist = {'t2-REG','t2-REGREG','t2-REGRAN','t1-REG','t1-REGREG','t1-REGRAN', 't3-REG','t3-REGREG','t3REGRAN'};   % condition labels
triglist = [10 30 50 70 90 110 20 40 60];
task1 = [70 90 110];
task2 = [10 30 50];
task3 = [20 40 60];
nblocks = 12;
sr= 600;              % sampling rate
epoch = [-0.2 0.15];   % epoch task 1 and 2

subjtorun = [24]; %

%% update with more subjects
sublist = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
twsubj  = [3 3 1 2 3 1 4 5 2  3  4  4  2  4  4  4  2  4  2  2  1  2  2  2  5  5];
tws = {[0.035 0.055],[0.055 0.085], [0.08 0.11], [0.09 0.12], [0.07 0.09]};
trigchan = 'UADC013';
dirloc = '';  % directory localiser to plot N1 based on auditory channels
getsubstr;
load CTF274_FIL_lay;
%% Loop through subjects (some subjects have different specifications)
for s = subjtorun
    tw =tws{twsubj(s)};
    fn = substr{1,s};
    nblocks = substr{3,s};
    if ismember(s, [1:6, 12])
        condlist = {'t2REG','t2REGREG','t2REGRAN','t1REG','t1REGREG','t1REGRAN'};   % condition labels
        triglist = [10 30 50 70 90 110];
    else
        condlist = {'t2-REG','t2-REGREG','t2-REGRAN','t1-REG','t1-REGREG','t1-REGRAN', 't3-REG','t3-REGREG','t3REGRAN'};   % condition labels
        triglist = [10 30 50 70 90 110 20 40 60];
    end
    %% Loop through blocks
    datatask = struct;% initialise data strct to store blocks
    for b = 1:nblocks
        file_raw = ['D:\PATTERN_INTERRUPT\DATA\Subject' num2str(s) filesep sprintf(fn,b)  '.ds'];%
        display(['SUBJECT' num2str(s) ', BLOCK' num2str(b)]);
        
        %% Define 'dummy' trial which is all data
        cfg = [];
        cfg.dataset =  file_raw;
        cfg.trialdef.triallength = Inf;
        cfg.trialdef.ntrials = 1;
        cfg = ft_definetrial(cfg);
        longdata = ft_preprocessing(cfg);
        hdr = longdata.hdr;
        
        %%  AND SELECT MEG CHANN
        cfg.channel='meg';
        longdata=ft_preprocessing(cfg,longdata);
        %datamat_original = nt_trial2mat(longdata.trial); % creates structure time * channel * trials
        
        %% DEFINE TRIAL
        cfg = [];
        cfg.header = hdr;
        cfg.headerformat = 'ctf_res4';
        cfg.trigchan = trigchan;
        cfg.conditionlabels = condlist;
        cfg.dataset =  [file_raw  '/' sprintf(fn,b) '.res4' ]; % your filename with file extension; MUST be the res4 file for MEG not the .ds folder
        cfg.trialdef.eventtype  = 'trigger_up'; % does the onset of the trigger go down(negative ) or up (positive)?
        cfg.trialdef.eventvalue = triglist; % your event value
        cfg.trialdef.conditionlabel = condlist;
        cfg.trialdef.prestim    = abs(epoch(1));  % before stimulation (sec), positive value means trial begins before trigger
        cfg.trialdef.poststim   = epoch(2); % after stimulation (sec) , only use positive value
        [cfg] = ft_definetrial_filMEG_RB(cfg, 0, 0.1); % second argument = plot triggers (0 if no)
        
        
        %% APPLY EPOCHs
        data = ft_redefinetrial(cfg, longdata);
        data = ft_preprocessing(cfg,data);
        time = data.time{1};
        data.trialinfo(:,3)= repmat(b, length(data.trialinfo),1); % add block information
        
        %% store data
        datatask.block(b) = data;
    end
    
    %% Merge BLOCKS by TASKS
    blockData = datatask.block;
    filename = ['ALL'];
    w =[];
    for i = 1:length(blockData)
        name = sprintf('blockData(%d), ', i);
        if i == length(blockData)
            name = sprintf('blockData(%d) ', i);
        end
        w = strcat(w, name);
    end
    fun = ['ft_appenddata(cfg,' w ')'];
    data = eval(fun);
    data.trialinfo(:,2) = 1:length(data.trialinfo); % append a column of info for trial number
    
    %% BASELINE
    cfg = [];
    cfg.demean = 'yes';
    cfg.baselinewindow = [epoch(1) 0];
    data = ft_preprocessing(cfg, data);
    
    %% AVERAGE ACROSS TRIALS
    cfg = [];
    cfg.channel = 'MEG';
    timelock = ft_timelockanalysis(cfg, data);
    timelock.fsample = 600;    
    
    %% finding the 20 strongest channels in each hemisphere
    M100dat=timelock.avg';

    t0 = abs(epoch(1))*timelock.fsample; % finds t = 0 since onset time window starts at -0.2
    amps=mean(M100dat((t0+tw(1)*timelock.fsample):(t0+tw(2)*timelock.fsample), :),1); 
    [ampsSorted,idx]=sort(amps,2,'descend'); % channels sorted by averaged M100 amplitude
    chnsSorted = timelock.label(idx);
    plot(timelock.time, M100dat);
    %selecting channels:    
    chns_selectedLpos=[];
    chns_selectedRpos=[];
    chns_selectedLneg=[];
    chns_selectedRneg=[];
    leftChansCountPos=0;
    rightChansCountPos=0;
    leftChansCountNeg=0;
    rightChansCountNeg=0;
    
    for count=1:length(ampsSorted)
        strPos=chnsSorted(count);
        strNeg=chnsSorted(end-count+1);
        % Lookup in Left Hemisphere
        if  ~isempty(strfind(strPos{1},'ML'))
            if(leftChansCountPos<10)
                leftChansCountPos=leftChansCountPos+1;
                chns_selectedLpos=[chns_selectedLpos strPos];
            end
        end
        if ~isempty(strfind(strNeg{1},'ML'))
            if(leftChansCountNeg<10)
                leftChansCountNeg=leftChansCountNeg+1;
                chns_selectedLneg=[chns_selectedLneg strNeg];
            end
            
        end
        
        % Lookup in Right Hemisphere
        if  ~isempty(strfind(strPos{1},'MR'))
            if(rightChansCountPos<10)
                rightChansCountPos=rightChansCountPos+1;
                chns_selectedRpos=[chns_selectedRpos strPos];
            end
        end
        if ~isempty(strfind(strNeg{1},'MR'))
            if(rightChansCountNeg<10)
                rightChansCountNeg=rightChansCountNeg+1;
                chns_selectedRneg=[chns_selectedRneg strNeg];
            end
        end
    end
    chns_selectedL = [chns_selectedLpos chns_selectedLneg];
    chns_selectedR = [chns_selectedRpos chns_selectedRneg];
    
    chnsL_num=[];
    for count1=1:length(timelock.label)
        for count2=1:length(chns_selectedL)
            if (strcmp(timelock.label{count1},chns_selectedL{count2}) ~= 0)
                chnsL_num=[chnsL_num count1];
            end
        end
    end
    chnsR_num=[];
    for count1=1:length(timelock.label)
        for count2=1:length(chns_selectedR)
            if (strcmp(timelock.label{count1},chns_selectedR{count2}) ~= 0)
                chnsR_num=[chnsR_num count1];
            end
        end
    end
    
    chns_selectedL = timelock.label(chnsL_num);
    chns_selectedR = timelock.label(chnsR_num);
    selected_dataL = timelock.avg(chnsL_num,:);
    time = timelock.time;
    
    figure(1);plot(time, selected_dataL)
    title ('LH channels');
    legend(chns_selectedL, 'Location','northwest');
    savefig([dir_out 'subj' num2str(s) '_timelock_leftCh']);
    selected_dataR = timelock.avg(chnsR_num,:);
    time = timelock.time;
    figure(2);plot(time, selected_dataR)
    title ('RH channels');
    legend(chns_selectedR, 'Location','northwest');
    savefig([dir_out 'subj' num2str(s) '_timelock_rightCh']);
    
%     
%      figure(1); plot(time, M100dat, 'k'); plot(time, selected_dataL, 'r'); hold on
%        plot(time, selected_dataR, 'b'); 
    %% PLOT TOPO
    cfg = [];
    % cfg.parameter = 'avg';
    cfg.layout='CTF274_FIL_lay';
    cfg.xlim=tw';
    cfg.marker = 'labels';
    cfg.interactive = 'yes';
    cfg.markerfontsize = 2;
    
    figure(3);
    channel = ft_channelselection([chns_selectedL, chns_selectedR], timelock.label);
    cfg = [];
    % cfg.parameter = 'avg';
    cfg.layout='CTF274_FIL_lay';
    cfg.interactive = 'yes';
    cfg.xlim=tw';
    cfg.marker = 'labels';
    cfg.interactive = 'yes';
    cfg.markerfontsize = 2;
    cfg.highlight='on';
    cfg.highlightchannel=channel;
    cfg.highlightfontsize=20;
    ft_topoplotER(cfg, timelock); title ('M100 response');
    savefig([dir_out 'subj' num2str(s) '_topoplot']);
    
    %% SAVE CHANNEL LIST AND FILE
    write_file = [ dir_out 'SelectedChannelsS' num2str(s)];
    save(write_file, 'channel')
%     writeFile  = [dir_out filename '_S' num2str(s) '.mat'];
%     save(writeFile, 'data', '-v7.3');    
    clear blockData datatask
    close all
end

