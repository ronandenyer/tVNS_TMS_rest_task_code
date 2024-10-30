function T = tVNS_TMS_rest_GenTable(subj_num,block_num,num_trials)
% RandDotsMotion_GenTable  Generate trial table for RandDotsMotionTask
%    T = RandDotsMotion_GenTable(subj_num,block_num,num_trials,duration_fixation_ms,duration_pre_ms)
%
%  Example:s
%
%       T = RandDotsMotion_GenTable(99,1,30);


%% Init Rand. Gen.
rng default
rng shuffle
%% TMS Timing parameters

tms_onset = [-1, 0.2, 1, 2, 3, 4, 5, 6, 7];

no_tms_onset = 7000; % tms onset parameter which refers to trial in which tms will not be triggered, i.e., noTMS trials

%% Create Trial Table
T = table();
m = num_trials;

T.subject = subj_num*ones(m,1);
T.block = block_num*ones(m,1);
T.stim_condition(1:18,1) = {'SHAM'};
T.stim_condition(19:36,1) = {'REAL'};
T.tms_asynchrony = ones(m,1);
T.no_tms_onset(1:36,1) = no_tms_onset;

for i = 1:length(tms_onset)
    T.tms_asynchrony(i,1) = tms_onset(i);
    T.tms_asynchrony(i+length(tms_onset),1) = tms_onset(i);
    T.tms_asynchrony(i+2*length(tms_onset),1) = tms_onset(i);
    T.tms_asynchrony(i+3*length(tms_onset),1) = tms_onset(i);
end

T.Trial(1:m,1) = randperm(m)';
T = sortrows(T, 'Trial');
%% 





