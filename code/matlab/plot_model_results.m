function plot_model_results(subj_idx,DEG_OF_FREEDOM,sorted_aic,bic,r_AIC,r_BIC,RND_THRESHOLD,best_aics)
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

    fh = figure();
    TITLE = ['Subject ',num2str(subj_idx)];
    
    number_best_models = sum(best_aics);
    number_total_models = 15;
    
    %subplot(1,2,1);
    bar(1:number_best_models,sorted_aic(1:number_best_models),'FaceColor',blue);
    hold on
    bar(number_best_models+1:number_total_models,sorted_aic(number_best_models+1:end),'FaceColor',red);
    %plot([0 length(DEG_OF_FREEDOM)+2],[r_AIC-RND_THRESHOLD,r_AIC-RND_THRESHOLD],'Color',red,'LineStyle','--','LineWidth',LW)
    ylabel('AIC');
    xlabel('Models');
    title(TITLE);
    %axis([0 length(DEG_OF_FREEDOM)+2 min(min(aic),min(bic))-RND_THRESHOLD 295]);   with random bar
    axis([0 length(DEG_OF_FREEDOM)+1 min(min(sorted_aic),min(bic))-RND_THRESHOLD max(sorted_aic)+5]);
    xticks([]);
    set(gca,'FontSize',FS);

%     subplot(1,2,2);
%     bar(1:length(DEG_OF_FREEDOM),bic,'FaceColor',blue);
%     hold on
%     bar(length(DEG_OF_FREEDOM)+1,r_BIC,'FaceColor',red);
%     plot([0 length(DEG_OF_FREEDOM)+2],[r_BIC-10,r_BIC-10],'Color',red,'LineStyle','--','LineWidth',LW)
%     ylabel('BIC');
%     xlabel('Models');
%     title(TITLE);
%     axis([0 length(DEG_OF_FREEDOM)+2 min(min(aic),min(bic))-BAR_OFFSET 295]);
%     xticks([]);
%     set(gca,'FontSize',FS);
%     hold off

end

