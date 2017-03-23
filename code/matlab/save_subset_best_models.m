function save_subset_best_models(file_path,file_name,best_multiple_models,model_selection_criterion)
%SAVE_SUBSET_BEST_MODELS 
%saves to csv file the single best model for each problem/subject
    
    if model_selection_criterion == 1
        msc = 'deltaAIC2';
    elseif model_selection_criterion == 2
        msc = 'weighted';
    end
    
    save_filename = [file_path, 'subset_best_models_',msc,'_',file_name];
    fileID = fopen(save_filename,'w');
    % [prob_id subj_id MLE alpha beta gamma AIC weight config]
    format_spec = '%f,%f,%f,%f,%f,%f,%s,%s,%s\n';
    [~,n_subjs] = size(best_multiple_models);
    for subj = 1:n_subjs
        [n_mods,~] = size(best_multiple_models{1,subj}{1,1});
        for mod_idx = 1:n_mods
            fprintf(fileID,'%f,%f,%f,%f,%f,%f,',best_multiple_models{1,subj}{1,1}(mod_idx,:));
            fprintf(fileID,'%f,%f,',best_multiple_models{1,subj}{1,3}(mod_idx,:),best_multiple_models{1,subj}{1,4}(mod_idx,:));
            fprintf(fileID,'%s,%s,%s\n',best_multiple_models{1,subj}{1,2}{mod_idx,:});
        end
    end
    fclose(fileID);