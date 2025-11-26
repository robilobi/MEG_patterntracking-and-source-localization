function fun_plot_components(c, ncomp, s, datalabel)
    load CTF274_FIL_lay;
for i=1:ncomp
    subplot(2, ncomp./2,i)
    tempdata=[];
    tempdata.time = 1:2;
    tempdata.avg = repmat(c(i,:)',1,length(c));
    tempdata.label = datalabel;
    

    cfg = [];
    cfg.layout = lay;
    tempdata.dimord = 'chan_time';
    
    cfg = [];
    cfg.parameter = 'avg';
    cfg.layout = lay;
    cfg.layout = ft_prepare_layout(cfg);
    cfg.xlim = 1:2; 
    cfg.markers = (tempdata.label(:));
    %cfg.interactive = 'yes';
    %cfg.colorbar = 'yes';
    tempdata.dimord = 'chan_time';
    cfg.highlightchannel = (tempdata.label(:)); %changed from (dat_av.label(:))
    cfg.interactive     = 'no';
    cfg.comment         = 'no';
    cfg.colorbar        = 'no';
    cfg.highlight       = 'off';
    cfg.highlightcolor  = 'k';
    cfg.highlightsymbol = '.';
    cfg.highlightsize   = 20;
    cfg.markersymbol    = '.';
    cfg.markersize      = 3;
    ft_topoplotER(cfg, tempdata);
end   
title(['Comp, S ' num2str(s)]);


 