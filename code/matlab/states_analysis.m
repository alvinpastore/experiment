function states_analysis(best_multiple_models)
%STATES ANALYSIS 
%Perform a pearson chi-squared test of the null hypothesis that the best
%models selected are equally distributed in the categories.
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
    states = [];
    for subj_idx = 1:length(best_multiple_models)
        states = [states; best_multiple_models{1,subj_idx}{1,2}(:,1)];
    end

                                                                  %better   %better     %all models
                                                                  %than     %than
                                                                  %random   %random
                                                                  %(2)      %(10)
                                                                
    num_full_history = sum(strcmp(states,'full_history'));        %142      %133        %142
    num_latest_outcome = sum(strcmp(states,'latest_outcome'));    %120      %114        %120
    num_stateless = sum(strcmp(states,'stateless'));              %57       %54         %57
    
    %% Chi-squared 
    
    observed_counts = [num_full_history, num_latest_outcome, num_stateless];
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
    xticklabels({'Full history','Latest outcome','Stateless'});
    
    set(gca,'FontSize',FONTSIZE);
    hold off;
    
    %% Print results to command window
    disp('Observed counts');
    disp(['2 states, full history: ',num2str(num_full_history),' - ',num2str(num_full_history/sum(observed_counts)),'%']);
    disp(['2 states, latest outcome: ',num2str(num_latest_outcome),' - ',num2str(num_latest_outcome/sum(observed_counts)),'%']);
    disp(['Stateless: ',num2str(num_stateless),' - ',num2str(num_stateless/sum(observed_counts)),'%']);
    disp('------------------------------');
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    %% Pairwise comparisons
    
    % 1 full history vs stateless
    observed_counts = [num_full_history, num_stateless];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    disp('-----------------');
    disp('full history vs stateless');
    disp(['Subset count: ',num2str(sum(observed_counts))]);
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    % 2 latest outcome vs stateless
    observed_counts = [num_latest_outcome, num_stateless];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    disp('-----------------');
    disp('latest outcome vs stateless');
    disp(['Subset count: ',num2str(sum(observed_counts))]);
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    % 3 full history vs latest outcome 
    observed_counts = [num_full_history, num_latest_outcome];
    NUM_CATEGORIES = size(observed_counts,2);
    expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
    dof = NUM_CATEGORIES - 1;
    
    chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);
    
    p = chi2cdf(chi2stat,1,'upper');
    disp('-----------------');
    disp('full history vs latest outcome');
    disp(['Subset count: ',num2str(sum(observed_counts))]);
    disp(['Chi-squared value = ',num2str(chi2stat)]);
    disp(['p-val = ',num2str(p)]);
    
    
    