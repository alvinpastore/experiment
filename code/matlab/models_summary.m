function models_summary(results,configs,best_multiple_models)

    %best_models_summary 
    %Create LATEX tables from set of best models
    
    %write to file
    SAVE_FILE = 0;
    
    %constants for calculations
    N_SUBJECTS = 12;
    N_PROBLEMS = 3;
    N_TRIALS = 200;
    DEG_OF_FREEDOM = get_dof(configs(1:15,2));
    
    % latex end row and column text constants
    table_row_end = '\\\\ \n';
    ampersand = ' & ';
    
    % state space constants
    stateless = 'stateless';
    full_history = 'full_history';
    latest_outcome = 'latest_outcome';
    SS = 'SS';
    FH = 'FH';
    LO = 'LO';
    
    % learning rule constants
    avg_tracking = 'avg_tracking';
    q_learning = 'q_learning';
    AT = 'AT';
    QL = 'QL';
    
    % reward function constants
    pt_value_func = 'pt_value_func';
    identity = 'identity';
    tanh = 'tanh';
    PT = 'PT';
    ID = 'ID';
    TH = 'TH';
    
    % variables to estimate percentage of subjects better than random
    num_subjs_better_than_random = 0;    
    AICs_all_models = [];
    
    for prob_idx = 0:N_PROBLEMS-1
        for subj_idx = 1:N_SUBJECTS
            
            subj_id = subj_idx + (12*(prob_idx));
            
            disp(['subj id ',num2str(subj_id)]);
            
            % get results and configurations in original order
            % uses subj_idx because in results subject ids are reset for each problem
            subj_models_results = results(results(:,1)==prob_idx & results(:,2)==subj_idx,:);
            
            %subj_models_configs = configs(1:15,:);
            
            % get MLEs
            MLEs = -subj_models_results(:,3);
            % get AICs
            [AICs,~] = aicbic(MLEs, DEG_OF_FREEDOM, N_TRIALS);
            % get delta_AICs
            AICd = AICs-min(AICs);
            % get w_AICs
            AICw = exp(-.5.*AICd) ./ sum(exp(-.5.*AICd));
            
            AICs_all_models = [AICs_all_models,AICs];
            
            % WRITE TO FILE (LaTeX)
            % table intro
            latex_content = ['\\begin{table}[!ht] \n',...
                             '\\centering \n',...
                             '\\begin{tabular}{cccccccc} \n',...
                             '\\hline \n',...
                             '\\multicolumn{3}{c}{Config} & No. Par$_i$ & $\\log(L_i)$ & AIC$_i$ & $\\Delta_i$(AIC) & $w_i$(AIC)',table_row_end,...
                             '\\hline \n'];

            % inspect each model in the 15 tested 
            for line_idx = 1:size(subj_models_results,1)
                
                % example
                % config    params  log(L)  AIC     DELTA(AIC)  w(AIC)
                % SS PT AT  2       123     231     2           0.5
                
                
                
                % check if the current configuration is in the best models
                % (by controlling if the current configuration triple is in
                % the set of best models triples) 
                % setdiff returns empty if it is in it
                % isempty returns 1 if the model is among the selected best 
                current_config = configs(line_idx,:);
                b_wrap_l = '';
                b_wrap_r = '';
                
                % count the number of models selected for the subject
                if ~isempty(best_multiple_models{1,subj_id})
                    num_best_models = size(best_multiple_models{1,subj_id}{1,2},1);
                else
                    num_best_models = 0;
                end
                    
                % boldify latex text for the subject's selected models 
                for best_config_idx = 1:num_best_models
                    current_best_conf = best_multiple_models{1,subj_id}{1,2}(best_config_idx,:);
                    if isempty(setdiff(current_config,current_best_conf))
                        b_wrap_l = '\\textbf{';
                        b_wrap_r = '}';
                    end
                end

                % write state in latex row 
                switch current_config{1}
                    case stateless
                        STATES_SPACE = SS; 
                    case full_history
                        STATES_SPACE = FH; 
                    case latest_outcome
                        STATES_SPACE = LO;  
                end
                latex_content = [latex_content,b_wrap_l,STATES_SPACE,b_wrap_r,ampersand]; 
                
                % write learning rule in latex row 
                switch current_config{2}
                    case avg_tracking
                        LEARN_RULE = AT;
                    case q_learning
                        LEARN_RULE = QL;
                end
                latex_content = [latex_content,b_wrap_l,LEARN_RULE,b_wrap_r,ampersand];
                
                % write reward function in latex row
                switch current_config{3}
                    case tanh
                        REW_FUN = TH;
                    case identity
                        REW_FUN = ID;
                    case pt_value_func
                        REW_FUN = PT;  
                end
                latex_content = [latex_content,b_wrap_l,REW_FUN,b_wrap_r,ampersand];
                
                % get number of parameters (depends on learning rule)
                current_n_params = DEG_OF_FREEDOM(line_idx);
                
                % get maximum likelihood estimate, AIC, delta_AIC, weight_AIC
                current_MLE  = MLEs(line_idx);
                current_AIC  = AICs(line_idx);
                current_AICd = AICd(line_idx);
                current_AICw = AICw(line_idx);
                
                % write model details
                latex_content = [latex_content,...
                                b_wrap_l,num2str(current_n_params),b_wrap_r,ampersand,...
                                b_wrap_l,num2str(current_MLE),b_wrap_r,ampersand,...
                                b_wrap_l,num2str(current_AIC),b_wrap_r,ampersand,...
                                b_wrap_l,num2str(current_AICd),b_wrap_r,ampersand,...
                                b_wrap_l,num2str(current_AICw),b_wrap_r,table_row_end];
                
                
            end
            
            % update the count of subjects better than random
            num_subjs_better_than_random = num_subjs_better_than_random + logical(num_best_models);
                
            % outro
            latex_content = [latex_content, '\\hline \n',...
                            '\\end{tabular} \n',...
                            '\\caption{Models summary: problem ',num2str(prob_idx+1),' - subject ',num2str(subj_idx),'} \n',...
                            '\\label{table:models_summary_subj_', num2str(subj_id),'}\n',...
                            '\\end{table} \n'];
            
            if SAVE_FILE 
                % save file 
                fid = fopen(['subject_',num2str(subj_id),'.txt'],'wt');
                fprintf(fid,latex_content);
                fclose(fid);
            end
        end
    end
    disp(['Subjects modelled better than random ',...
    num2str(num_subjs_better_than_random),'/',num2str(N_SUBJECTS*N_PROBLEMS),' = ',...
    num2str(100*(num_subjs_better_than_random/(N_SUBJECTS*N_PROBLEMS))),'%']);
    AICs_all_models = AICs_all_models(:)';
    disp('Statistics on all AIC values');
    disp(['Median: ',num2str(median(AICs_all_models))]);
    disp(['Mean: ',num2str(mean(AICs_all_models))]);
    
end

