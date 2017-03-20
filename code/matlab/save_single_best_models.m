function save_single_best_models(file_path,file_name,best_models)
%SAVE_SINGLE_BEST_MODELS 
%saves to csv file the single best model for each problem/subject

    fileID = fopen([file_path, 'BEST_MODELS_', file_name],'w');
    format_spec = '%f,%f,%f,%f,%f,%f,%s,%s,%s\n';
    [nrows,ncols] = size(best_models);
    for row = 1:nrows
        fprintf(fileID,format_spec,best_models{row,:});
    end

    fclose(fileID);