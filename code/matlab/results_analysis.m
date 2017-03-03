clear;
close all;

%% LOAD DATA
file_path = '../../results/';
%file_name = 'results_test_greedy_random_generic__2017-03-02.csv'; %TEST
file_name = 'results_BarronErev2003_Thaler_replication.csv__2017-02-28.csv';
fid = fopen([file_path,file_name]);
format_spec = '%f %f %f %f %f %f %s %s %s';
results_data = textscan(fid, format_spec, 'delimiter', ',');
fclose(fid);

% matrix of results with prob_id, subj_id, MLE, theta
results = cell2mat(results_data(1:6));  
% cell array of strings (it can be reduced to the first 15 and use an offset multiplication)
configurations = horzcat(results_data{7:end}); 

%% Find and store best model for each player

SUBJECT_LINES_NUMBER = 15; % each subject has 15 lines
% subjs number = num of subj in each problem x number of problems
PROBS_NUMBER = size(unique(results(:,1)),1);
SUBJS_NUMBER = size(unique(results(:,2)),1);

best_models = cell(SUBJS_NUMBER * PROBS_NUMBER,9);

for prob_idx = 0:PROBS_NUMBER-1 % problems ids start from 0
    
    % get subset of results for prob_id
    prob_results_all_probs = results(results(:,1) == prob_idx,:);
    
    for subj_idx = 1:SUBJS_NUMBER % subjects ids start from 1
        
        subj_res = prob_results_all_probs(prob_results_all_probs(:,2) == subj_idx,:);
        % find best model based on MLE
        [best_model_MLE, best_model_line] = min(subj_res(:,3));

        % get the results and config for the best model
        subj_best_model_res = subj_res(best_model_line,:);
        subj_best_model_config = configurations(best_model_line,:);

        % store in cell array
        res_idx = (prob_idx * SUBJS_NUMBER) + subj_idx;
        res_values = num2cell(subj_best_model_res);
        best_models(res_idx,:) = {res_values{:}, subj_best_model_config{:}};
        
    end
end


%% SAVE BEST MODELS RESULTS TO CSV FILE
fileID = fopen([file_path, 'BEST_MODELS_', file_name],'w');
format_spec = '%f,%f,%f,%f,%f,%f,%s,%s,%s\n';
[nrows,ncols] = size(best_models);
for row = 1:nrows
    fprintf(fileID,format_spec,best_models{row,:});
end

fclose(fileID);


clearvars -except best_models
