function states_analysis(best_multiple_models)
    
    states = [];
    for subj_idx = 1:length(best_multiple_models)
        states = [states; best_multiple_models{1,subj_idx}{1,2}(:,1)];
    end
    
    num_full_history = sum(strcmp(states,'full_history'));      %142
    num_latest_outcome = sum(strcmp(states,'latest_outcome'));  %120
    num_stateless = sum(strcmp(states,'stateless'));            %57

