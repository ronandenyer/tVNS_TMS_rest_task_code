%% Generate participant blocks
% This script will iterate over function tVNS_TMS_rest_GenTable
% to creqte 10 distinct blocks of trials for participants in the tVNS_TMS_rest
% experiment
%%
subj_num = 1;
total_blocks = 10;
num_trials = 36;

base_dir = 'C:\MATLAB\Ronan\tVNS_rest\Task_data\';

pat_dir = char(strcat(base_dir, string(subj_num), '\'));

if ~isdir(pat_dir)
    mkdir(pat_dir);
end

%%
for block_num = 1:total_blocks
    T = tVNS_TMS_rest_GenTable(subj_num,block_num,num_trials);
    filename = sprintf('tVNS_TMS_rest_subject-%d_block-%d%s',subj_num, block_num);
    filename = fullfile(pat_dir,filename);
    save(filename) % save everything mat-file (always do that, for safety)

    
end