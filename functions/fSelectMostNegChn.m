function [chns_selectedNEG, chns_selectedPOS] = fSelectMostNegChn(timelock, plotfig, fs)

   timelock.fsample = fs;

%% finding the 20 strongest channels in each hemisphere
    M100dat=timelock.avg';
    tw = [2.10 2.20]; 
    epoch = [timelock.time(1) timelock.time(end)];
    t0 = abs(epoch(1))*timelock.fsample+1; % finds t = 0 since onset time window starts at -0.2
    amps=mean(M100dat((t0+tw(1)*timelock.fsample):(t0+tw(2)*timelock.fsample), :),1); 
    [ampsSorted,idx]=sort(amps,2,'descend'); % channels sorted by averaged M100 amplitude
    chnsSorted = timelock.label(idx);
%     plot(timelock.time, M100dat);
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
%     chns_selectedL = [chns_selectedLpos chns_selectedLneg];
%     chns_selectedR = [chns_selectedRpos chns_selectedRneg];
    chns_selectedNEG = [ chns_selectedLneg chns_selectedRneg];
    chns_selectedPOS = [chns_selectedLpos chns_selectedRpos];
    
    chnsN_num=[];
    for count1=1:length(timelock.label)
        for count2=1:length(chns_selectedNEG)
            if (strcmp(timelock.label{count1},chns_selectedNEG{count2}) ~= 0)
                chnsN_num=[chnsN_num count1];
            end
        end
    end
    chnsP_num=[];
    for count1=1:length(timelock.label)
        for count2=1:length(chns_selectedPOS)
            if (strcmp(timelock.label{count1},chns_selectedPOS{count2}) ~= 0)
                chnsP_num=[chnsP_num count1];
            end
        end
    end
    
    chns_selectedNEG = timelock.label(chnsN_num);
    chns_selectedPOS = timelock.label(chnsP_num);
    selected_dataL = timelock.avg(chnsN_num,:);
    time = timelock.time;
    
    if plotfig
    figure(1);plot(time, selected_dataL)
    title ('NEG channels');
%     legend(chns_selectedNEG, 'Location','northwest');
%     savefig([dir_out 'subj' num2str(s) '_timelock_leftCh']);
    selected_dataR = timelock.avg(chnsP_num,:);
    time = timelock.time;
    figure(2);plot(time, selected_dataR)
    title ('POS channels');
%     legend(chns_selectedPOS, 'Location','northwest');
%     savefig([dir_out 'subj' num2str(s) '_timelock_rightCh']);
    
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
    channel = ft_channelselection([chns_selectedNEG], timelock.label);
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
%     savefig([dir_out 'subj' num2str(s) '_topoplot']);
    end
end