function models_summary(full_models_results,full_models_configs,best_multiple_models)

    %best_models_summary Summary of this function goes here
    %Create LATEX tables from set of best models

    number_subjects = size(best_multiple_models,2);
    number_problems = 3;
    
    for prob_idx = 1:number_problems
        for subj_idx = 1:number_subjects

            subj_models_results = full_models_results(full_models_results(:,1)==0 & full_models_results(:,2)==1,:);
            subj_models_configs = full_models_configs(1:15,:);
            
            
            %FIND BEST MODELS (SELECTED) AND BOLDIFY
            best_subj_models = best_multiple_models{1,subj_idx};
            
            %WRITE TO FILE (LaTeX)
            latex_content = '';
            for line_idx = 1:size(subj_models_results)
                model_details = sprintf('%.5f,',subj_models_results(line_idx,:));
                latex_content = [latex_content,model_details];
                latex_content = [latex_content(1:end-1),'\n'];
                
            end
            
            fid = fopen(['test',num2str(subj_idx),'.txt'],'wt');
            fprintf(fid,latex_content);
            fclose(fid);
        end
        
        
    end
    
    
end

