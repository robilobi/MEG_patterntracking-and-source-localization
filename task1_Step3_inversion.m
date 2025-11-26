%% Inversion: Single subject and group
%  Script will create a D structure of subjects and new inversions within
%  each subject. Inversions can be called using D{sub}.inv{invNum}, with
%  sub referring to subjects in the D structure and invNum the inversion
%  from the subject. For example, D{1}.inv{2} would call the second
%  inversion from the first subject.
%  If group inversion, then these will save as invNum + 1
cd('D:\PATTERN_INTERRUPT\SCRIPTS\scriptsSource');
addpath(genpath('D:\MAToolBox\spm12'));
spm('defaults', 'EEG');
clear all

coreg = 'D:\PATTERN_INTERRUPT\RESULTS\Step2_DSSfullepoch_45Hz\Source\Task1\'; 
subjects = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26]; %task 1 e 2
condLabels = {'t1-REG','t1-REGREG','t1-REGRAN'};   % condition labels
type = {'GS'}; %
It = 1;  %%%Inversion Number
WOI= [2000 3000]; % 3 cycles
comment = '2000-3000';
sub = 1;
for i = subjects % loop arond subjects for single subject inversions
    disp(['loading subject_' num2str(i)]);
    data = [coreg 'mD_' num2str(i) '.mat'];
    D{sub} = spm_eeg_load(data);
    D{sub}.inv{It} = D{sub}.inv{1};  %%copy forward filed into new inevrsion from the first inve GS
    D{sub}.inv{It}.inverse.method = {'Imaging'};
    D{sub}.inv{It}.comment = {[comment '_' type{1}]}; %label of inversion
    D{sub}.inv{It}.inverse.modality = {'MEG'};
    D{sub}.inv{It}.inverse.woi = WOI;  %window of interest
%     D{sub}.inv{It}.inverse.lpf = 0;           %low pass filter
%     D{sub}.inv{It}.inverse.hpf = 30;            %high pass fitler
    D{sub}.inv{It}.inverse.Han = 0;
    D{sub}.inv{It}.inverse.trials = condLabels;
    D{sub}.inv{It}.inverse.type   = type{1};
    D{sub}.inv{It}.inverse.Np = 256;            %patches per hemisphere
    D{sub} = spm_eeg_invert(D{sub}, It);
    D{sub}.save;  
    sub = sub +1;
end
