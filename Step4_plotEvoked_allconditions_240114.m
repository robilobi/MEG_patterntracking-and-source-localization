%% Analysis of EEG ERP data of LEARNREG20_EEG
% fieldtrip
% Computes the root mean square (RMS) condsition by condsition and plots it:
% _ for all trials and selected channels accross each subject (rms).
% _ for all subjects (grms).
%
%
% Analysis of difference between condsitions is using FieldTrip
% Cluster-based stats

clear; close all;
clearvars; close all
addpath(genpath('D:\MAToolBox\fieldtrip-20171128'));
addpath(genpath('D:\MAToolBox\miscscripts'));

%=========================== PATH
cd('D:\PATTERN_INTERRUPT\SCRIPTS\');
dir_ft = '../RESULTS/';
path_in= 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\';
plot_path = [path_in '/Plots_final/']; mkdir(plot_path);


% %=========================== conds DEFINITION
filelist = {'TASK1_fullepoch', 'TASK2_fullepoch', 'TASK3_fullepoch'};
condlists = {{'t1-REG','t1-REGREG','t1-REGRAN'},{ 't2-REG','t2-REGREG','t2-REGRAN'},{ 't3-REG','t3-REGREG','t3-REGRAN'}};   % condition labels
triglists = {[70 90 110], [10 30 50], [20 40 60]};
statpairs = [1 2; 1 3; 2 3]; % which condss to compare per block type; 6 2; 6 3; 6 4; 6 5
conds = [1 2 3];

%=========================== VAR SETTINGS
neeg =40;
stats           = 1; % include stats based on cluster stats
save_plots      = 1; % save plots to PDF file

for task = 1:3
    if task == 2
        C=[128 128 128; %
            127 0 255; %
            0 204 0]/255; %;
    else
        C=[128 128 128; %
            255 0 255; %
            0 204 0]/255; %
    end
    file_in = ['AVG_DSS5_TASK' num2str(task) '_S'];
    
    % task = input(prompt);
    if task == 3
        sublist = [7 8 9 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
        tw = [-0.5 3];
        baseline =[0.9 1];
        twtoplot = [1.8 2.2];
    else
        sublist = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
        tw = [-0.5 5.5];
        baseline =[1.9 2];
        twtoplot = [3.8 4.2];
    end
    subexclude = [];  %
    s =length(sublist);
    
    file = filelist{task};
    condlist = condlists{task};
    triglist = triglists{task};
    [subplotRC,unu]=numSubplots(numel(sublist)+1);
   
    %% Load in
    load([path_in file_in num2str(s) '.mat']);
    
    
    %% plot topographies
        reg =    alldata(:,1);
        regreg=  alldata(:,2);
        regran=  alldata(:,3);
        
        cfg = [];
        cfg.channel = 'all';
        cfg.latency = 'all';
        cfg.parameter = 'avg';
        grandavg_regreg = ft_timelockgrandaverage(cfg, regreg{:});
        grandavg_regran = ft_timelockgrandaverage(cfg, regran{:});
          
        cfg = [];
        cfg.operation = 'subtract';
        cfg.parameter = 'avg';
        difference= ft_math(cfg,  grandavg_regreg, grandavg_regran);
        
        
        
        
        
        
    %% Bootstrap sd and mean
    time = alldata(1,1,1).time;
    twbsl = find(time > baseline(1) & time < baseline(2)); % in sec
    twbsl =[twbsl(1) twbsl(end)];
    B = 1000;
    for ci = conds
        x=[];
        for si=1:length(sublist)
            x(:,si) = alldata(si,ci).rmsavg;
            thissubjx = alldata(si,ci).rmsavg;
            alldata(si,ci).rmsavgbsl = thissubjx-mean(thissubjx(twbsl(1):twbsl(2)));
        end
        %baseline
%         x=x-mean(x(twbsl(1):twbsl(2), :),1);
        plot(time, mean(x,2)); hold on;
        %  Force x to be time*repetitions
        if size(x,2) > size(x,1), x=x'; end
        [mn,sd]=fBootstrapMean(x,B);
        bsmean(ci,:)=mn';
        bsstd(ci,:)=sd';
    end
    
    %% Plot individual RMS for each subject 
    time = alldata(1,1,1).time;
    f = figure(2); clf; set(gcf,'Position',[1 1 900 900])
    for si = 1:size(alldata,1) % loop over all subjects
        if size(alldata,1) > 1
%             subplot(subplotRC(1),subplotRC(2),si)
              subplot(7,4,si)

        end
        for ci = conds % loop over all condsitions
            h= plot(time,alldata(si,ci).rmsavg,'LineWidth',0.2,'color',C(ci,:)); hold on;
        end
        hold on;
        ylim([0 max([alldata(:).rmsavg])]);
        xlim([-.5 4]);
        if si == 1
            ylabel('\bf RMS (T)');
%             xlabel('\bf Time (s)');
        end
        if s ~= 1
            xticks([]);
            yticks([]);
        end
        title(['s' num2str(si)]);
    end
    if size(alldata,1) > 1
%         subplot(subplotRC(1),subplotRC(2),si+1)
        subplot(7,4,si+1)
        for  ci = conds
            % plot some dummy data for making legend in it's own subplot
            plot(1,1,'color',C(ci,:)); hold on;
        end
        axis off
    end
    %lh = legend(condslist(conds),'fontweight','b','Location','best');
    suptitle(['RMS ' num2str(size(alldata,1)) ...
        ' subs, '  num2str(neeg) ' channs,  \rm File: ' file_in]);
%     set(f,'Position',[10 10  1400  400]);
    
    if save_plots
        set(f,'color',[1 1 1]);
        export_fig(f,'-painters','-q101',[plot_path 'singleSubjRMS_' file_in  num2str(size(alldata,1)) '.fig']);
        export_fig(f,'-dpng',[plot_path 'singleSubjRMS_' file_in  num2str(size(alldata,1)) '.png']);
        print(f,'-dpdf','-bestfit',[plot_path 'singleSubjRMS_' file_in  num2str(size(alldata,1)) '.pdf'])

    end
    
    rmpath('D:\MAToolBox\fieldtrip-20171128');
   rmpath('D:\MAToolBox\miscscripts');
    %% --------Plot group RMS + bootstrap (+ stats)----------
    h=[];
    f = figure(3); clf; ax1 = gca;
    set(f,'Position',[1 1 900 500])
    for ci = conds % loop over all condsitions
        a = squeeze(bsmean(ci,:))';
        h = [h;plot(time,a,'LineWidth',1,'color',C(ci,:))]; hold on;
        % plot Se bars
        b = squeeze(bsstd(ci,:))';  %SE of boostrap resampling
        %b=b * 1e9;
        Y = [b+a;flipud(-b+a)]';
        X = [time(:); flipud(time(:))];
        hp = fill(X,Y,C(ci,:),'edgecolor','none','facealpha',0.2); hold on;
        set(gca,'children',flipud(get(gca,'children'))); % Send shaded areas in background
    end
    
    legh = legend(h,condlist(conds),'fontweight','b','AutoUpdate','off');
    set(legh,'Location','Northwest'); legend boxoff
    xlabel('\bf Time (s)');
    ylabel('\bf RMS amplitude (T)');
    lab = get(gca,'XLabel');
    set(gca,'XLabel',lab,'FontName','Arial','fontsize',18)
    xlim([-1 6]);
    % ylim([0 1]);
    grid off;
    
    %% Plot stats (based on DATA baselined at the change)
    if stats
        addpath(genpath('D:\MAToolBox\fieldtrip-20171128'));
        aa = ylim; aa = (aa(2)-aa(1))/30;
        Ystat = 3*aa;
        for k = 1:size(statpairs,1)
            for si=1:size(alldata,1)
                conds1(:,si) = alldata(si,statpairs(k,1)).rmsavgbsl;
                conds2(:,si) = alldata(si,statpairs(k,2)).rmsavgbsl;
            end
            % perform the statistical test using randomization and a clustering approach
            cfg = [];
            %cfg.avgoverchan      = 1;
            cfg.statistic        = 'ft_statfun_depsamplesT';
            cfg.latency = [-.5 5];
            cfg.numrandomization = 1000;
            cfg.correctm         = 'cluster';
            cfg.method           = 'montecarlo';
            cfg.tail             = 0;
            cfg.clusteralpha     = 0.05;
            cfg.alpha            = 0.05/2;
            cfg.design           = [1:size(alldata,1) 1:size(alldata,1) % subject number
                ones(1,size(alldata,1)) 2*ones(1,size(alldata,1))];  % condsition number
            cfg.uvar = 1;        % "subject" is unit of observation
            cfg.ivar = 2;        % "condsition" is the independent variable
            cfg.dimord = 'time_subj';
            cfg.dim=[1,numel(time)];
            cfg.connectivity =0;
            
            stat = ft_statistics_montecarlo(cfg, [conds1 conds2],cfg.design);
            
            % Find indices of significant clusters
            pos=[]; neg=[];
            if isfield(stat,'posclusters')
                if ~isempty(stat.posclusters)
                    pos_cluster_pvals = [stat.posclusters(:).prob];
                    pos_signif_clust = find(pos_cluster_pvals < cfg.alpha);
                    poss = ismember(stat.posclusterslabelmat, pos_signif_clust);
                    pos = [find(diff([0; poss])==1) find(diff([0; poss])==-1)];
                    if ~isempty(pos)
                        for j = 1:size(pos,1)
                            line([time(pos(j,1)) time(pos(j,2))],[Ystat Ystat],...
                                'LineWidth',4,'Color',C(statpairs(k,2),:));hold on
                        end
                    end
                end
            end
            if isfield(stat, 'negclusters')
                if ~isempty(stat.negclusters)
                    neg_cluster_pvals = [stat.negclusters(:).prob];
                    neg_signif_clust = find(neg_cluster_pvals <cfg.alpha);
                    negs = ismember(stat.negclusterslabelmat, neg_signif_clust);
                    neg = [find(diff([0; negs])==1) find(diff([0; negs])==-1)];
                    if ~isempty(neg)
                        for j = 1:size(neg,1)
                            line([time(neg(j,1)) time(neg(j,2))],[Ystat Ystat], ...
                                'LineWidth',4,'Color',C(statpairs(k,2),:));hold on
                        end
                    end
                end
            end
            
            % divergence time (not necc when significant, just when means differ
            meandiff(k,:) = mean(conds1,2)-mean(conds2,2);
            Ystat = Ystat+aa;
        end
        hold off;
    end
    
    rmpath(genpath('D:\MAToolBox\fieldtrip-20171128'));
     addpath(genpath('D:\MAToolBox\miscscripts'));

    if save_plots
        set(f,'color',[1 1 1]);
        export_fig(f,'-painters','-q101',[plot_path 'groupRMS_' file_in  num2str(size(alldata,1)) '.fig'])
        print(f,'-dpng',[plot_path 'groupRMS_' file_in  num2str(size(alldata,1)) '.png'], '-r600')
          print(f,'-dpdf', '-bestfit',[plot_path 'groupRMS_' file_in  num2str(size(alldata,1)) '.pdf'])
    end
    
    clear bsmean bsstd conds1 conds2 meandiff
    
    
    
    
    %% find the data points for the effect of interest in the grand average
    timesel = find(time >= twtoplot(1) & time <= twtoplot(2));
    
    % select the individual subject data and calculate the mean
    for iSub = 1:numel(sublist)
        values_reg(iSub) = mean(alldata(iSub, 1).rmsavg(timesel));
        values_regreg(iSub) = mean(alldata(iSub, 2).rmsavg(timesel));
        values_regran(iSub) = mean(alldata(iSub, 3).rmsavg(timesel));
    end
        % plot to see the effect in each subject
    M = [ values_reg', values_regreg', values_regran'];
   
    f = figure(99); clf; ax1 = gca;
    set(f,'Position',[1 1 500 400])
    plot(M', 'o-'); xlim([0.5 3.5]); hold on;
    boxplot(M, 'Labels', condlist); 
    if save_plots
        set(f,'color',[1 1 1]);
        export_fig(f,'-painters','-q101',[plot_path 'mean_boxplot_sustr' file_in  num2str(size(alldata,1)) '.fig'])
        print(f,'-dpng',[plot_path 'mean_boxplot_sustr' file_in  num2str(size(alldata,1)) '.png'], '-r600')
        print(f,'-dpdf',[plot_path 'mean_boxplot_sustr' file_in  num2str(size(alldata,1)) '.pdf'])
    end
end
