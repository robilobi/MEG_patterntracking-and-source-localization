function [pos, neg]=fClusterbasedPermTest(conds1, conds2, N, time, clusteralpha)

addpath(genpath('D:\MAToolBox\fieldtrip-20171128'));
%         aa = ylim; aa = (aa(2)-aa(1))/30;
%         Ystat = 3*aa;
%         for k = 1:size(statpairs,1)
%             for si=1:size(alldata,1)
%                 conds1(:,si) = alldata(si,statpairs(k,1)).rmsavgbsl;
%                 conds2(:,si) = alldata(si,statpairs(k,2)).rmsavgbsl;
%             end
            % perform the statistical test using randomization and a clustering approach
            cfg = [];
            %cfg.avgoverchan      = 1;
            cfg.statistic        = 'ft_statfun_depsamplesT';
            cfg.latency = [time(1) time(end)];
            cfg.numrandomization = 1000;
            cfg.correctm         = 'cluster';
            cfg.method           = 'montecarlo';
            cfg.tail             = 0;
            cfg.clusteralpha     = clusteralpha;  %this is the threshold used to form clusters from the test statistic (e.g., t-values)
            cfg.alpha            = 0.025;  %This is the critical alpha level used to assess overall statistical significance of the clusters after permutation testing.
            cfg.design           = [1:N 1:N % subject number
                                    ones(1,N) 2*ones(1,N)];  % condsition number
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
                    pos = [find(diff([0; poss; 0])==1) find(diff([0; poss; 0])==-1)];
                   if  ~isempty(pos); if pos(end) > size(time); pos(end) = pos(end)-1; end; end
%                     if ~isempty(pos)
%                         for j = 1:size(pos,1)
%                             line([time(pos(j,1)) time(pos(j,2))],[Ystat Ystat],...
%                                 'LineWidth',4,'Color',C(statpairs(k,2),:));hold on
%                         end
%                     end
                end
            end
            if isfield(stat, 'negclusters')
                if ~isempty(stat.negclusters)
                    neg_cluster_pvals = [stat.negclusters(:).prob];
                    neg_signif_clust = find(neg_cluster_pvals <cfg.alpha);
                    negs = ismember(stat.negclusterslabelmat, neg_signif_clust);
                    neg = [find(diff([0; negs; 0])==1) find(diff([0; negs; 0])==-1)];
                    if  ~isempty(neg)
                    if neg(end) > size(time); neg(end) = neg(end)-1; end
                    end

%                     if ~isempty(neg)
%                         for j = 1:size(neg,1)
%                             line([time(neg(j,1)) time(neg(j,2))],[Ystat Ystat], ...
%                                 'LineWidth',4,'Color',C(statpairs(k,2),:));hold on
%                         end
%                     end
                end
            end
            
            % divergence time (not necc when significant, just when means differ
%             meandiff(k,:) = mean(conds1,2)-mean(conds2,2);
%             Ystat = Ystat+aa;
%         end
%         hold off;

    rmpath(genpath('D:\MAToolBox\fieldtrip-20171128'));
