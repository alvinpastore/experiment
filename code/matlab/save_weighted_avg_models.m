function save_weighted_avg_models(file_path,file_name,best_models)
%SAVE_WEIGHTED_AVG_MODELS
%saves to csv file the single best model for each problem/subject
%estimated as the weighted average of the parameters 
%using Akaike weights

    fileID = fopen([file_path, 'best_weighted_avg_models_', file_name],'w');
    format_spec = '%f,%f,%f,%f,%f\n';
    [nrows,ncols] = size(best_models);
    for row = 1:nrows
        fprintf(fileID,format_spec,best_models(row,:));
    end

    fclose(fileID);
end