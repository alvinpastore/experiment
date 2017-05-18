function reward_functions_analysis(best_multiple_models)
%REWARD_FUNCTIONS_ANALYSIS 
%Perform a pearson chi-squared test of the null hypothesis that the best
%models selected are equally distributed in the categories of reward function adopted.
%Is the variation due to chance or due to the variable tested (category)?
%


    close all;
    
    %% CONSTANTS
    % figures constants
    MARKERSIZE = 30;
    LINEWIDTH = 3;
    FONTSIZE = 20;
    red = [215,25,28]/255;
    orange = [253,174,97]/255;
    green = [171,221,164]/255;
    blue = [43,131,186]/255;
    black = [0.5,0.5,0.5];
    
    %% extract model categories from best models 
    rew_func = [];
    for subj_idx = 1:length(best_multiple_models)
        rew_func = [rew_func; best_multiple_models{1,subj_idx}{1,2}(:,3)];
    end

                                                             %better   
                                                             %than     
                                                             %random   
                                                             %(2)      
                                                                
    num_pt_vf = sum(strcmp(rew_func,'pt_value_func'));       %125      
    num_tanh = sum(strcmp(rew_func,'tanh'));                 %86      
    num_iden = sum(strcmp(rew_func,'identity'));             %108      
    
    %% Chi-squared 
    
    observed_counts = [num_pt_vf, num_tanh, num_iden];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    
    %% Figures
    figure();
    hold on;
    bar(observed_counts,'FaceColor',blue);
    plot([0,2,4],ones(1,3)*expected_counts,'r-','LineWidth',LINEWIDTH);
    axis([0.5 3.5 0 max(observed_counts)+10]);
    legend('Observed models count','Expected uniform distribution','Location','NorthEast');
    %xlabel('State-space configuration');
    ylabel('Count');
    xticks([1,2,3]);
    xticklabels({'PT Value Function','Hypebolic tangent','Identity (raw payoff)'});
    
    set(gca,'FontSize',FONTSIZE);
    hold off;
    
    %% Print results to command window
    disp('Observed counts');
    disp(['PT value function: ',num2str(num_pt_vf),' - ',num2str(num_pt_vf/sum(observed_counts)),'%']);
    disp(['hyperbolic tangent: ',num2str(num_tanh),' - ',num2str(num_tanh/sum(observed_counts)),'%']);
    disp(['Identity: ',num2str(num_iden),' - ',num2str(num_iden/sum(observed_counts)),'%']);
    disp('------------------------------');
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    %% Pairwise comparisons
    
    % 1 PT value function vs identity
    observed_counts = [num_pt_vf, num_iden];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    disp('-----------------');
    disp('PT value function vs identity');
    disp(['Subset count: ',num2str(sum(observed_counts))]);
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    % 2 Hyperbolic tangent vs identity
    observed_counts = [num_tanh, num_iden];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    disp('-----------------');
    disp('Hyperbolic tangent vs identity');
    disp(['Subset count: ',num2str(sum(observed_counts))]);
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    % 3 PT value function vs hyperbolic tangent
    observed_counts = [num_pt_vf, num_tanh];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    disp('-----------------');
    disp('PT value function vs hyperbolic tangent');
    disp(['Subset count: ',num2str(sum(observed_counts))]);
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
end

    