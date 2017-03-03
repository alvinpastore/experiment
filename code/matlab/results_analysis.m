clear;
close all;

%% PLOT CONSTANTS
FS = 20;
LW = 2;
BAR_OFFSET = 10;
% colors
red = [215,25,28]/255;
orange = [253,174,97]/255;
green = [171,221,164]/255;
blue = [43,131,186]/255;
black = [0.5,0.5,0.5];

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
        TITLE = ['Subject ',num2str(subj_idx)];
        subj_res = prob_results_all_probs(prob_results_all_probs(:,2) == subj_idx,:);
        
        [aic,bic] = aicbic(-subj_res(:,3), DEG_OF_FREEDOM, N_TRIALS);
           
        fh = figure();
        
        subplot(1,2,1);
        bar(1:length(DEG_OF_FREEDOM),aic,'FaceColor',blue);
        hold on
        bar(length(DEG_OF_FREEDOM)+1,r_AIC,'FaceColor',red);
        plot([0 length(DEG_OF_FREEDOM)+2],[r_AIC-10,r_AIC-10],'Color',red,'LineStyle','--','LineWidth',LW)
        ylabel('AIC');
        xlabel('Models');
        title(TITLE);
        axis([0 length(DEG_OF_FREEDOM)+2 min(min(aic),min(bic))-BAR_OFFSET 295]);
        xticks([]);
        set(gca,'FontSize',FS);
        
        subplot(1,2,2);
        bar(1:length(DEG_OF_FREEDOM),bic,'FaceColor',blue);
        hold on
        bar(length(DEG_OF_FREEDOM)+1,r_BIC,'FaceColor',red);
        plot([0 length(DEG_OF_FREEDOM)+2],[r_BIC-10,r_BIC-10],'Color',red,'LineStyle','--','LineWidth',LW)
        ylabel('BIC');
        xlabel('Models');
        title(TITLE);
        axis([0 length(DEG_OF_FREEDOM)+2 min(min(aic),min(bic))-BAR_OFFSET 295]);
        xticks([]);
        set(gca,'FontSize',FS);
        hold off
        
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

SAVE = 0

if SAVE
    %% SAVE BEST MODELS RESULTS TO CSV FILE
    fileID = fopen([file_path, 'BEST_MODELS_', file_name],'w');
    format_spec = '%f,%f,%f,%f,%f,%f,%s,%s,%s\n';
    [nrows,ncols] = size(best_models);
    for row = 1:nrows
        fprintf(fileID,format_spec,best_models{row,:});
    end

    fclose(fileID);
end

clearvars -except best_models
