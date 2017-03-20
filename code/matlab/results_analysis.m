clear;
close all;

% CONSTANTS for subroutines
SAVE_SINGLE_BEST_MODELS = 0;
SAVE_BEST_MODELS_SUBSET = 0;
PLOT_FIGURE = 0;


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
N_TRIALS = 200; % the number of interactions
DEG_OF_FREEDOM = get_dof(configurations(1:15,2));

% calculate MLE and AIC/BIC for random model
random_model_MLE = N_TRIALS * log(1/2);
% second term is 0 because of no params
r_AIC = - 2 * random_model_MLE + (2 * 0); 
r_BIC = - 2 * random_model_MLE + (log(N_TRIALS) * 0);

% data structure to store the single best models (according to lowest MLE)
best_models = cell(SUBJS_NUMBER * PROBS_NUMBER,9);

for prob_idx = 0:PROBS_NUMBER-1 % problems ids start from 0
    
    % get subset of results for prob_id
    prob_results_all_probs = results(results(:,1) == prob_idx,:);
    
    for subj_idx = 1:SUBJS_NUMBER % subjects ids start from 1
        
        
        % get the subject results
        subj_res = prob_results_all_probs(prob_results_all_probs(:,2) == subj_idx,:);
        
        [aic,bic] = aicbic(-subj_res(:,3), DEG_OF_FREEDOM, N_TRIALS);
        
        if PLOT_FIGURE
            plot_model_results(subj_idx,DEG_OF_FREEDOM,aic,bic,r_AIC,r_BIC);
        end
        
        %% SINGLE BEST MODEL 
        % find best model based on MLE
        [best_model_MLE, best_model_line] = min(subj_res(:,3));

        % get the results and config for the best model
        subj_best_model_res = subj_res(best_model_line,:);
        subj_best_model_config = configurations(best_model_line,:);
        
        % store in cell array single best model
        res_idx = (prob_idx * SUBJS_NUMBER) + subj_idx;
        res_values = num2cell(subj_best_model_res);
        best_models(res_idx,:) = {res_values{:}, subj_best_model_config{:}};
        
        % save single best models
        if SAVE_SINGLE_BEST_MODELS
            save_single_best_models(file_path,file_name,best_models);
        end
        
        %% SUBSET OF BEST MODELS
        % sort the models according to lowest aic first
        [~,aic_idx] = sortrows(aic);
        sorted_results = subj_res(aic_idx,:);
        sorted_configs = configurations(aic_idx,:);
        
        
    end
end




clearvars -except best_models
