
function [meanB1, meanB2, meanB3, meanB4] = fBootstrap_nested(data1,data2, data3, data4, B)

%% function for bootstrapping the data
% input
% data: num of subject x timepoint data
% B   : num of iteration
% output
% meanB: B x timepoimt data (for each iteration, the mean of 24 x timepoint
% data is cauculated to generate 1 x timepoint data)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

[NS,~] = size(data1);
%meandata = mean(data);

p = repmat(1:NS,B,1); % rep number of 1:24 for the number of iteration
p = p(reshape(randperm(B*NS),B,NS)); % shuffle the number (each iteration possibly include same number)

meanB1 = zeros(length(data1),B);
meanB2 = zeros(length(data2),B);
meanB3 = zeros(length(data3),B);
meanB4 = zeros(length(data4),B);

for b = 1:B % for each iteration
    meanB1(:,b) = mean(data1(p(b,:),:)); % calculate the mean across all subjects listed in p 
    meanB2(:,b) = mean(data2(p(b,:),:));
    meanB3(:,b) = mean(data3(p(b,:),:)); 
    meanB4(:,b) = mean(data4(p(b,:),:));
end
end