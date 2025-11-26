%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Roberta Bianco 03/2021
% Load and prepocess MEG data
% - Load session by session
% - (Filter power line noise 50Hz out)
% - Cut in epochs
% - merge sessions into different tasks based on triggers found
% - remove outlier trials
% - plot N1 (based on auditory channels if there is a localiser)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rehash toolboxcache
restoredefaultpath
addpath('D:\MAToolBox\fieldtrip-20171128');
addpath('D:\MAToolBox\NoiseTools');
ft_defaults;
clearvars; close all

%% Definine Settings
sublist = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
%sublist = [23 24 25 26];

dir_out = 'D:\PATTERN_INTERRUPT\RESULTS\Step1_DefineTrial\'; mkdir(dir_out);
condlist = {'t2-REG','t2-REGREG','t2-REGRAN','t1-REG','t1-REGREG','t1-REGRAN', 't3-REG','t3-REGREG','t3REGRAN'};   % condition labels
triglist = [10 30 50 70 90 110 20 40 60];
task1 = [70 90 110];
task2 = [10 30 50];
task3 = [20 40 60];
nblocks = 12;
filterlinenoise = 0;  % optional to filter 50Hz
sr= 600;              % sampling rate
epoch = [-0.5 5.5];   % epoch task 1 and 2
epoch2 = [-0.5 3.75]; % epoch task3

trigchan = 'UADC013';
dirloc = 'D:\PATTERN_INTERRUPT\RESULTS\Step0_Selectchannels\';  % directory localiser to plot N1 based on auditory channels
getsubstr;

%% Loop through subjects (some subjects have different specifications)
for s = sublist
  
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
    t1=1; t2=1; t3=1;
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
        
        %% AND FILTER POWER LINE NOISE 50Hz
        if filterlinenoise
            datamat = nt_trial2mat(longdata.trial); % creates structure time * channel * trials
            x = datamat(:,:,:);
            x= x(1:cfg.trl(end,2)+1, :); % cut to end of recording to allow proper demean
            x=nt_demean(x);
            FLINE=50/sr; % line frequency
            NREMOVE=20; % number of components to remove
            p.nkeep=50; % reduce dimensionality before DSS to avoid overfitting
            tic; [y, yy]=nt_zapline(x,FLINE,NREMOVE,p); toc; %return cleaned data in y, noise in yy, don't plot
            datamat(1:size(y,1),:)=y;  % replace demeand cleaned data into data structure
            longdata.trial{1}=datamat';
            
            tic; nt_zapline(x,FLINE,NREMOVE,p); toc; % plot cleaned and removed data
            series=y(1:1000);
            [Px, F]=pwelch(series,[],[],[],sr);
        end
        
        %% APPLY EPOCHs
        data = ft_redefinetrial(cfg, longdata);
        data = ft_preprocessing(cfg,data);
        time = data.time{1};
        data.trialinfo(:,3)= repmat(b, length(data.trialinfo),1); % add block information
        
        %% store data in different structures based on triggers found
        trgfound = unique(data.trialinfo(:,1));
        if mean(ismember( trgfound, task1))==1
            datatask(1).block(t1) = data;
            datatask(1).task = 1;
            t1 = t1+1;
        elseif mean(ismember( trgfound, task2))==1
            datatask(2).block(t2) = data;
            datatask(2).task = 2;
            t2 = t2+1;
        elseif mean(ismember( trgfound, task3))==1
            %% trim excess ISI in task 3
            cfg=[];
            cfg.latency = epoch2;
            data = ft_selectdata(cfg,data);
            datatask(3).block(t3) = data;
            datatask(3).task = 3;
            t3 = t3+1;
        end
    end
    
    %% Merge BLOCKS by TASKS
    for n = 1:size(datatask,2)
        blockData = datatask(n).block;
        filename = ['TASK' num2str(datatask(n).task)];
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
        
        %% REMOVE OUTLIER TRIALS
        x = cat(3,data.trial{:});
        x = permute(x,[2 1 3]); % nt_find_outlier_trials requires input structure time * channels * trials)
        xb = nt_demean(x, find(time<0)); %baseline
        THRESH = 2; % Reject trials that deviate from the mean by more than twice the average deviation from the mean
        good_trials=nt_find_outlier_trials(xb, THRESH); % creates array with good trials based on threshold
        save([dir_out 'good_trials_S' num2str(s) '_' filename], 'good_trials');
        cfg = [];
        cfg.trials = good_trials;
        data = ft_selectdata(cfg, data); % amend data to only keep good trials
        writeFile  = [dir_out filename '_S' num2str(s) '.mat'];
        save(writeFile, 'data', '-v7.3');
        
        fun_plot_N1(data, s, [0.07 0.12], [epoch(1) 0], 1, dirloc)  %%% data, subj ID, time window to average, baseline, use localiser 1/0, directory localiser
        saveas(gcf, [dir_out, 'topo_07-1s_S', num2str(s) '_' filename], 'png');
    end
    clear blockData filenames datatask
    close all
end

