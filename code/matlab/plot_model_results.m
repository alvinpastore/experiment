function plot_model_results(subj_idx,DEG_OF_FREEDOM,sorted_aic,bic,r_AIC,r_BIC,RND_THRESHOLD,best_aics,sorted_configs)
%PLOT_MODEL_RESULTS 
%plot results of a problem/subject to single figure, 2 columns AIC/BIC subplots
% 
    %% PLOT CONSTANTS
    FS = 20;
    LW = 2;
    
    % colors
    red = [215,25,28]/255;
    orange = [253,174,97]/255;
    green = [171,221,164]/255;
    blue = [43,131,186]/255;
    black = [0.5,0.5,0.5];
    mustard = [235, 156, 20]/255;
    
    state_space_colors = {'stateless',orange;'latest_outcome',blue;'full_history',green};

    fh = figure();
    TITLE = ['Subject ',num2str(subj_idx)];
    hold on;
    
    number_best_models = sum(best_aics);
    number_total_models = length(best_aics);
    
    % plot a bar for each model (color-coded with the type of state-space)
    % loop over the best_aics
    for bar_idx = 1:number_best_models
        
        switch sorted_configs{bar_idx}
            case state_space_colors{1,1}
                bar_color = state_space_colors{1,2};
            case state_space_colors{2,1}
                bar_color = state_space_colors{2,2};
            case state_space_colors{3,1}
                bar_color = state_space_colors{3,2};
        end
        
        bar(bar_idx,sorted_aic(bar_idx),'FaceColor',bar_color);
    end
    
    bar(number_best_models+1:number_total_models,sorted_aic(number_best_models+1:end),'FaceColor',red);
    %plot([0 length(DEG_OF_FREEDOM)+2],[r_AIC-RND_THRESHOLD,r_AIC-RND_THRESHOLD],'Color',red,'LineStyle','--','LineWidth',LW)
    ylabel('AIC');
    xlabel('Models');
    title(TITLE);
    %axis([0 length(DEG_OF_FREEDOM)+2 min(min(aic),min(bic))-RND_THRESHOLD 295]);   with random bar
    axis([0 length(DEG_OF_FREEDOM)+1 min(min(sorted_aic),min(bic))-RND_THRESHOLD max(sorted_aic)+5]);
    xticks([]);
    set(gca,'FontSize',FS);


end

