clear;
close all;

% CONSTANTS for subroutines
SAVE_SINGLE_BEST_MODELS = 0;
SAVE_SUBSET_BEST_MODELS = 0;
PLOT_FIGURES = 1;
STATES_ANALYSIS = 0;
REWARD_FUNCTIONS_ANALYSIS = 0;
CORRELATION_ANALYSIS = 0;

% Subset generation method 
% 1 -> delta_AIC; 2 -> AIC weights 
SUBSET_METHOD = 2;

% threshold criteria for model selection
AIC_DIFF_THRESHOLD = 2;  % Burnham Anderson 2002 page 131
RND_THRESHOLD = 2;       % 10 is very strong evidence. 2 is bare minum!
WEIGHT_THRESHOLD = 0.95; % "For a 95% confidence set on the actual K-L best model"  Burnham Anderson 2002 page 169

%% LOAD DATA
file_path = '../../results/';
%file_name = 'results_test_greedy_random_generic__2017-03-02.csv'; %TEST
file_name = 'results_BarronErev2003_Thaler_replication__2017-03-20_MLE.csv';
fid = fopen([file_path,file_name]);
format_spec = '%f %f %f %f %f %f %s %s %s %*[^\n]';
results_data = textscan(fid, format_spec, 'delimiter', ',');
fclose(fid);

% matrix of results with prob_id, subj_id, MLE, theta
results = cell2mat(results_data(1:6));  
% cell array of strings (it can be reduced to the first 15 and use an offset multiplication)
configurations = horzcat(results_data{7:end}); 

%% Find and store best model for each player

SUBJECT_LINES_NUMBER = 15; % each subject has 15 lines
PROBS_NUMBER = size(unique(results(:,1)),1);
SUBJS_NUMBER = size(unique(results(:,2)),1);
N_TRIALS = 200; % the number of interactions
DEG_OF_FREEDOM = get_dof(configurations(1:15,2));

% calculate MLE and AIC/BIC for random model
random_model_MLE = N_TRIALS * log(1/2);
% second term is 0 because of no params
r_AIC = - 2 * random_model_MLE + (2 * 0); 
r_BIC = - 2 * random_model_MLE + (log(N_TRIALS) * 0);

% data structure to store the single best models (according to weighted average)
best_models = zeros(SUBJS_NUMBER * PROBS_NUMBER,5);

% data structure to store the best models subset 
% according to eitherd delta_AIC or sum of Ak. weights
best_multiple_models = cell(1);
multiple_model_idx = 1;

for prob_idx = 0:PROBS_NUMBER-1 % problems ids start from 0
    
    % get subset of results for prob_id
    prob_results_all_probs = results(results(:,1) == prob_idx,:);
    
    for subj_idx = 1:SUBJS_NUMBER % subjects ids start from 1
        
        
        % get the subject results
        subj_res = prob_results_all_probs(prob_results_all_probs(:,2) == subj_idx,:);
        
        [aic,bic] = aicbic(-subj_res(:,3), DEG_OF_FREEDOM, N_TRIALS);
        
        % skip the analysis for players with no model significantly better than random
        if min(aic) < (r_AIC - RND_THRESHOLD)
        
            %% find the subset of best models 
            % sort the models according to lowest aic
            [sorted_aic,aic_idx] = sortrows(aic);
            sorted_results = subj_res(aic_idx,:);
            sorted_configs = configurations(aic_idx,:);

            % calculate AIC differences (deltas)
            AICd = sorted_aic-min(sorted_aic);

            if SUBSET_METHOD == 1 % delta_AIC method

                % logical array: 1 for first AIC differences values (below threshold), 0 for the rest
                best_aics = AICd < AIC_DIFF_THRESHOLD;

            elseif SUBSET_METHOD == 2 % Akaike weights method

                % calculate Akaike weights
                AICw = exp(-.5.*AICd) ./ sum(exp(-.5.*AICd));

                % get subset of weights that adds up to 95%
                for weight_idx = 1:length(AICw)
                    if sum(AICw(1:weight_idx)) > WEIGHT_THRESHOLD
                        % logical array: 1 for first weight_idx values, 0 for the rest
                        best_aics = AICw >= AICw(weight_idx);
                        break
                    end
                end

                %% Estimate single best model as a weighted average of the
                % subset (normalised on sum of weights cumulatively > 0.95)
                weighted_average_params = sum(sorted_results(best_aics,4:6).*AICw(best_aics))/sum(AICw(best_aics));

                % store value in result structure's correct position 
                res_idx = (prob_idx * SUBJS_NUMBER) + subj_idx;
                best_models(res_idx,:) = [prob_idx, subj_idx, weighted_average_params];
                
                if PLOT_FIGURES
                    plot_model_results(subj_idx,DEG_OF_FREEDOM,sorted_aic,bic,r_AIC,r_BIC,RND_THRESHOLD,best_aics,sorted_configs);
                end
            end

            %% Save the subset of best models 
            % [prob_id subj_id MLE alpha beta gamma AIC weight config]
            disp(['Prob: ',num2str(prob_idx),' subj: ', num2str(subj_idx),' models: ',num2str(sum(best_aics))]);
            best_multiple_models{multiple_model_idx} = {sorted_results(best_aics,:),sorted_configs(best_aics,:),sorted_aic(best_aics,:),AICw(best_aics,:)};
            multiple_model_idx = multiple_model_idx + 1;
        else
            disp(['Subj: ',num2str(subj_idx),': no model better than random']);
        end
    end
end

% Store single models only if weighted avg was used 
if SAVE_SINGLE_BEST_MODELS  && SUBSET_METHOD == 2
    save_weighted_avg_models(file_path,file_name,best_models);
end

% Store subset of best models
if SAVE_SUBSET_BEST_MODELS
    save_subset_best_models(file_path,file_name,best_multiple_models,SUBSET_METHOD);
end

if STATES_ANALYSIS
    states_analysis(best_multiple_models);
end

if REWARD_FUNCTIONS_ANALYSIS
    reward_functions_analysis(best_multiple_models);
end

if CORRELATION_ANALYSIS
    correlations_analysis(best_models);
end

%Matrix_2 = Matrix_1( [1:2,4:8,10:end] , : ) method to remove a row from a
%matrix (in case it is necessary to remove models, maybe outliers) 
 
clearvars -except best_models best_multiple_models
