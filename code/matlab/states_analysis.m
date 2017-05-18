function states_analysis(best_multiple_models)
%STATES ANALYSIS 
%Perform a pearson chi-squared test of the null hypothesis that the best
%models selected are equally distributed in the categories.
%Is the variation due to chance or due to the variable tested (category)?
%

    close all;
    NUM_CATEGORIES = 5;
    
    %% CONSTANTS
    % figures constants
    MARKERSIZE = 30;
    LINEWIDTH = 3;
    FONTSIZE = 20;
    
    red = [235, 49, 20]/255;
    orange = [235, 88, 20]/255;
    mustard = [235, 156, 20]/255;
    yellow = [235, 217, 20]/255;
    green1 = [175, 222, 33]/255;
    green2 = [69, 210, 45]/255;
    green3 = [38, 147, 60]/255;
    tale = [28, 227, 154]/255;
    blue1 = [28, 227, 207]/255;
    blue2 = [28, 210, 227]/255;
    blue3 = [28, 161, 227]/255;
    blue4 = [34, 90, 221]/255;
    purple = [144, 117, 219]/255;
    lavander = [184, 117, 219]/255;
    pink1 = [219, 117, 219]/255;
    pink2 = [219, 117, 155]/255;
    
    %% extract state-space and learning rule categories from best models 
    states = [];
    for subj_idx = 1:length(best_multiple_models)
        states = [states; best_multiple_models{1,subj_idx}{1,2}];
    end

    if NUM_CATEGORIES == 3
        
        % for frequency estimation consider only avg-tracking 
        % (no qlearning as it would make the bins uneven)

        num_full_history_at   = sum(strcmp(states(:,1),'full_history')    );        %60    57          
        num_latest_outcome_at = sum(strcmp(states(:,1),'latest_outcome')  );        %50    48 
        num_stateless        = sum(strcmp(states(:,1),'stateless')        );         %57    54  
        
        observed_counts = [num_full_history_at, num_latest_outcome_at, num_stateless];
        %strcmp(states(:,1),'full_history') && strcmp(states(:,2),'avg_tracking')
        %% Chi-squared 

        NUM_CATEGORIES = size(observed_counts,2);
        %expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        expected_counts = [2/5 2/5 1/5] .* sum(observed_counts);
        
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');

        %% Figures
        figure();
        hold on;
        bar(observed_counts,'FaceColor',blue);
        plot([0.5,1.5],ones(1,2)*expected_counts(1),'r-','LineWidth',LINEWIDTH);
        plot([1.5,2.5],ones(1,2)*expected_counts(2),'r-','LineWidth',LINEWIDTH);
        plot([2.5,3.5],ones(1,2)*expected_counts(3),'r-','LineWidth',LINEWIDTH);
        
        axis([0.5 3.5 0 max(observed_counts)+10]);
        legend('Observed models count','Expected uniform distribution','Location','SouthEast');
        %xlabel('State-space configuration');
        ylabel('Count');
        xticks([1,2,3]);
        xticklabels({'Full history','Latest outcome','Stateless'});

        set(gca,'FontSize',FONTSIZE);
        hold off;

        %% Print results to command window
        disp('Observed counts');
        disp(['2 states, full history: ',num2str(num_full_history_at),' - ',num2str(num_full_history_at/sum(observed_counts)),'%']);
        disp(['2 states, latest outcome: ',num2str(num_latest_outcome_at),' - ',num2str(num_latest_outcome_at/sum(observed_counts)),'%']);
        disp(['Stateless: ',num2str(num_stateless),' - ',num2str(num_stateless/sum(observed_counts)),'%']);
        disp('------------------------------');
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);

        %% Pairwise comparisons

        % 1 full history vs stateless
        observed_counts = [num_full_history_at, num_stateless];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = [2/3 1/3] .* sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history vs stateless');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);

        % 2 latest outcome vs stateless
        observed_counts = [num_latest_outcome_at, num_stateless];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = [2/3 1/3] .* sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('latest outcome vs stateless');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);

        % 3 full history vs latest outcome 
        observed_counts = [num_full_history_at, num_latest_outcome_at];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = [1/2 1/2] .* sum(observed_counts);
        
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history vs latest outcome');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
    elseif NUM_CATEGORIES == 5 
        % for frequency estimation consider q_l and a_t as separate categories (total 5 cats) 
                                                                                                                        %threshold

                                                                                                                        % 2    10
        num_full_history_ql   = sum(strcmp(states(:,1),'full_history')   .* strcmp(states(:,2),'q_learning'));          %14    57          
        num_latest_outcome_ql = sum(strcmp(states(:,1),'latest_outcome') .* strcmp(states(:,2),'q_learning'));          %13    48 
        num_full_history_at   = sum(strcmp(states(:,1),'full_history')   .* strcmp(states(:,2),'avg_tracking'));        %19    57          
        num_latest_outcome_at = sum(strcmp(states(:,1),'latest_outcome') .* strcmp(states(:,2),'avg_tracking'));        %2     48 
        num_stateless         = sum(strcmp(states(:,1),'stateless'));                                                   %24    54

        observed_counts = [num_full_history_ql, num_full_history_at, num_latest_outcome_ql, num_latest_outcome_at, num_stateless];
        
        %% Chi-squared 

        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');

        %% Figures
        figure();
        hold on;
        bar(1,observed_counts(1),'FaceColor',blue3);
        bar(2,observed_counts(2),'FaceColor',blue4);
        bar(3,observed_counts(3),'FaceColor',green2);
        bar(4,observed_counts(4),'FaceColor',green3);
        bar(5,observed_counts(5),'FaceColor',yellow);
        plot(0:2:8,ones(1,NUM_CATEGORIES)*expected_counts,'Color',red,'LineWidth',LINEWIDTH);
        
        legend('Full history Q-learning ',...
               'Full history Avg-tracking ',...
               'Latest outcome Q-learning ',...
               'Latest outcome Avg-tracking ',...
               'Stateless',...
               'Exp. uniform distribution ',...
               'Location','NorthEast');
        
        axis([0.5 5.5 0 max(observed_counts)+10]);
        %legend('Observed models count','Expected uniform distribution','Location','NorthEast');
        %xlabel('State-space configuration');
        ylabel('Count');
        xticks([1,2,3,4,5]);
        xticklabels({'Full QL','Full AT','Latest QL','Latest AT','Stateless'});

        set(gca,'FontSize',FONTSIZE+5);
        hold off;
        
        %% Print results to command window
        disp('Observed counts');
        disp(['2 states, full history at: ',    num2str(num_full_history_at),' - ',     num2str(num_full_history_at/sum(observed_counts)),'%']);
        disp(['2 states, latest outcome at: ',  num2str(num_latest_outcome_at),' - ',   num2str(num_latest_outcome_at/sum(observed_counts)),'%']);
        disp(['2 states, full history ql: ',    num2str(num_full_history_ql),' - ',     num2str(num_full_history_ql/sum(observed_counts)),'%']);
        disp(['2 states, latest outcome ql: ',  num2str(num_latest_outcome_ql),' - ',   num2str(num_latest_outcome_ql/sum(observed_counts)),'%']);
        disp(['Stateless: ',                    num2str(num_stateless),' - ',           num2str(num_stateless/sum(observed_counts)),'%']);
        disp('------------------------------');
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        %% Pairwise comparisons
        %% full hist ql vs others
        % 1.1 full hist ql vs full hist at
        observed_counts = [num_full_history_ql, num_full_history_at];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history ql vs full history at');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        % 1.2 full hist ql vs latest outcome ql
        observed_counts = [num_full_history_ql, num_latest_outcome_ql];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history ql vs latest outcome ql');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        % 1.3 full hist ql vs latest outcome at
        observed_counts = [num_full_history_ql, num_latest_outcome_at];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history ql vs latest outcome at');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        % 1.4 full hist ql vs stateless
        observed_counts = [num_full_history_ql, num_stateless];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history ql vs stateless');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        %% full hist at vs others
        % 1.1 full hist at vs latest outcome ql
        observed_counts = [num_full_history_at, num_latest_outcome_ql];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history at vs latest outcome ql');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        % 1.2 full hist at vs latest outcome at
        observed_counts = [num_full_history_at, num_latest_outcome_at];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history at vs latest outcome at');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        % 1.3 full hist at vs stateless
        observed_counts = [num_full_history_at, num_stateless];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('full history at vs stateless');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        %% stateless vs others
        % 1.1 stateless vs latest outcome ql
        observed_counts = [num_stateless, num_latest_outcome_ql];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('stateless at vs latest outcome ql');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
        
        % 1.2 stateless at vs latest outcome at
        observed_counts = [num_stateless, num_latest_outcome_at];
        NUM_CATEGORIES = size(observed_counts,2);
        expected_counts = 1 / NUM_CATEGORIES * sum(observed_counts);
        dof = NUM_CATEGORIES - 1;

        chi2stat = sum((observed_counts - expected_counts).^2 ./ expected_counts);

        p = chi2cdf(chi2stat,dof,'upper');
        disp('-----------------');
        disp('stateless at vs latest outcome at');
        disp(['Subset count: ',num2str(sum(observed_counts))]);
        disp(['Chi-squared value = ',num2str(chi2stat)]);
        disp(['p-val = ',num2str(p)]);
    end
end
    

    