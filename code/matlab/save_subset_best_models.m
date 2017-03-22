function save_subset_best_models(file_path,file_name,best_multiple_models)
%SAVE_SINGLE_BEST_MODELS 
%saves to csv file the single best model for each problem/subject

    fileID = fopen([file_path, 'BEST_MODELS_SUBSET_', file_name],'w');
    format_spec = '%f,%f,%f,%f,%f,%f,%s,%s,%s\n';
    [~,n_subjs] = size(best_multiple_models);
    for subj = 1:n_subjs
        [n_mods,~] = size(best_multiple_models{1,subj}{1,1});
        for mod_idx = 1:n_mods
            fprintf(fileID,'%f,%f,%f,%f,%f,%f,',best_multiple_models{1,subj}{1,1}(mod_idx,:));
            fprintf(fileID,'%s,%s,%s\n',best_multiple_models{1,subj}{1,2}{mod_idx,:});
        end
    end
    fclose(fileID);