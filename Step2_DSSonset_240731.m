%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Roberta Bianco 03/2021
% DSS preprocessed data by subject
% - Load subject data
% - baseline before stimulus onset
% - find most replicable component across trials (MERGE TASK 1 AND TASK 2)
% - plot time course of the components
% - keep first 3 components
% - save weight matrix and dssed data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('D:\MAToolBox\fieldtrip-20171128'));
addpath(genpath('D:\MAToolBox\miscscripts'));
addpath('D:\MAToolBox\NoiseTools');
clearvars; close all
%% setup
sublist = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];

dir_sub = '';
dir_ft = '../RESULTS/';
path_in = [dir_ft 'Step1_DefineTrial/' dir_sub ];
dir_out = [dir_ft 'Step2_DSSfullepoch_45Hz_final/' dir_sub ]; mkdir(dir_out);
file_in = {'TASK1_S', 'TASK2_S', 'TASK3_S'}; % stem of filename to read in (i.e. from last step of prepro 1)
epoch = {[-0.5 5.5], [-0.5 5.5], [-0.5 3.75]};

readyToRemove = 1;
dodss=1;
scount=0;
comptokeep= 5;
bslwindow = [-0.1 0];
referencezero = 0;  % from where to compute the baseline for dss


for s = sublist
    if ismember(s, [1:6, 12])
        file_in = {'TASK1_S', 'TASK2_S'}; % stem of filename to read in (i.e. from last step of prepro 1)
        loop = 1;
    else
        file_in = {'TASK1_S', 'TASK2_S', 'TASK3_S'}; % stem of filename to read in (i.e. from last step of prepro 1)
        loop = 1:2;
    end
    
    for t = loop %length(file_in)
        clear data ccov comp x dssweights datamat data_dssed
        scount = scount + 1;
        if t ==1
            t1 = load([path_in file_in{t} num2str(s) '.mat']); % load task 1
            t2 = load([path_in file_in{t+1} num2str(s) '.mat']); % load task 2
            cfg = [];
            data = ft_appenddata(cfg, t1.data, t2.data);
            label = 'TASK1-2_fullepoch'; 
            latencydss = [-0.1 4.5] ; % time range in sec used to compute DSS, finds the most repeatable comp in this time window
        elseif t == 2
            load([path_in file_in{t+1} num2str(s) '.mat']); % load task 3
            label = 'TASK3_fullepoch';
            latencydss = [-0.1 2.25] ; % time range in sec used to compute DSS, finds the most repeatable comp in this time window
        end
        %         %% trim excess ISI
        %         cfg=[];
        %         cfg.latency =epoch{t};
        %         data = ft_selectdata(cfg,data);
%         % Downsample
% %         cfg = [];
% %         cfg.resamplefs = 200;
% %         cfg.detrend = 'no';
% %         data= ft_resampledata(cfg,data);

        %% Low pass needs to be at most 0.5* downsamplefs because of aliasing
        LPf = 45;
        cfg = [];
        cfg.lpfilter = 'yes';
        cfg.lpfreq = LPf;
        cfg.lpfiltord = 5;
        data = ft_preprocessing(cfg,data);
        
%         %% Baseline Correct
%         cfg = [];
%         cfg.demean = 'no';
%         cfg.baselinewindow = bslwindow;
%         data = ft_preprocessing(cfg, data);
%            [ databs ] = fun_Manual_BaseCorr( data, [-100 0] );
           
        %% prepare data and baseline correct 
        datamat = nt_trial2mat(data.trial); % creates structure time * channel * trials
        time = data.time{1};
        
        [val, time_index(1)] = min(abs(time-latencydss(1))); % returns cell corresponding to t = 0
        [val, time_index(2)] = min(abs(time-latencydss(2))); % returns cell corresponding to t = 0.4
        time2 = time(time_index(1): time_index(2)); % array of time steps between 0 - 0.4
        x = datamat(time_index(1):time_index(2),:,:); % new data structure from datamat with above time interval
        % baseline/demean
        %x = nt_demean(x); % use nt_demean() instead if there's a strong trend
        x = nt_demean2(x, find(time2<referencezero | time2==referencezero));
%         x = nt_demean2(x, find(time2<referencezero ));
        %% 2. do DSS
        close all
        [dssweights,pwr0,pwr1] = nt_dss1(x); % todss = 'denoising matrix', i.e. nchanns x nchanns matrix of weights for each component
        comp = nt_mmat(datamat,dssweights); % matrix multiplication of data structure and denoising matrix. time * components * trial.
        f1 = figure(1); clf; plot(pwr1./pwr0,'.-'); ylabel('score'); xlabel('component');
        
        f2 = figure(2); clf;
        for iComp=1:10
            subplot(2,5,iComp);
            nt_bsplot(comp(:,iComp,:),[],[],time);
            title(iComp);
            xlim([time(1) time(end)]); xlabel('s');
        end
        % use function 'fun_plot_components' to plot topography
        dssplots = [dir_ft dir_out 'components/' dir_sub];
        mkdir(dssplots)
        export_fig(f1,'-dpng',[dssplots 'compScore_' label '_Sub' num2str(s) '.png'])
        export_fig(f2,'-dpng',[dssplots 'compTime_' label '_Sub' num2str(s) '.png'])
        
        % SAVE components
        writeFile  = [dir_ft dir_out 'components/' dir_sub 'comp_' file_in{t} num2str(s) '.mat'];
        save(writeFile, 'comp', '-v7.3');
        
        %% 3. Project back into sensor space the components that you want
        % (do this after you have run the above dss on all subjects to extract & plot the compone t timeseries, and decided how
        % many components to keep!!)
        if readyToRemove
            for k = comptokeep
                KEEP = 1:k; % all of the components to keep, i.e. if you want first 3, enter KEEP = 1:3
                %ccov = nt_xcov(comp,datamat); % c is cross-covariance between component and data across all time steps. Components * channel.
                ccov = nt_xcov(comp, datamat)/(size(comp,1)*size(comp,3));
                data_dssed = nt_mmat(comp(:,KEEP,:),ccov(KEEP,:)); % matrix multiplication of kept components of ccv and comp matrix, creating new time * channel * trial matrix
                data.trial = nt_mat2trial(data_dssed); % replaces data.trial with dssed data
                
                mkdir([dir_ft dir_out dir_sub]);
                writeFile  = [dir_out dir_sub 'DSS' num2str(length(KEEP)) '_' label '_Sub' num2str(s) '.mat'];
                save(writeFile, 'data', '-v7.3');
            end
        end
    end
end