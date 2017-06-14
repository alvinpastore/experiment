function correlations_analysis(best_models)
    
    close all;
    
    % CONSTANTS
    % figures constants
    MARKERSIZE = 30;
    LINEWIDTH = 2;
    FONTSIZE = 25;
    red = [215,25,28]/255;
    orange = [253,174,97]/255;
    green = [171,221,164]/255;
    blue = [43,131,186]/255;
    black = [0.5,0.5,0.5];
    
    % indexing constants
    cond1 = 1:12;
    cond2 = 13:24;
    cond3 = 25:36;
    conditions = cell(36,1);
    conditions(cond1) = {'Condition 1'};
    conditions(cond2) = {'Condition 2'};
    conditions(cond3) = {'Condition 3'};
    
    condition1_means = [25,100];
    condition1_stds = [17.7,354];
    condition2_means = [1225,1300];
    condition2_stds = [17.7,354];
    condition3_means = [1225,1300];
    condition3_stds = [17.7,17.7];
    
    
    %% LOAD PV and subjects performances
    file_path = '../../results/';
    %file_name = 'results_test_greedy_random_generic__2017-03-02.csv'; %TEST
    file_name = 'measures_BarronErev2003_Thaler_replication.csv';
    fid = fopen([file_path,file_name]);
    format_spec = '%f %f %f %f %f';
    measures_data = textscan(fid, format_spec, 'delimiter', ',');
    fclose(fid);

%     problem_id = measures_data{:,1};
%     subj_id = measures_data{:,2};
    

    

    performances = measures_data{:,3};
    % normalise each condition performance (accumulated outcomes)
    % experienced in that subgroup
%     performances(cond1,1) = (original_performances(cond1) - mean(original_performances(cond1))) ./ std(original_performances(cond1)) ;
%     performances(cond2,1) = (original_performances(cond2) - mean(original_performances(cond2))) ./ std(original_performances(cond2));
%     performances(cond3,1) = (original_performances(cond3) - mean(original_performances(cond3))) ./ std(original_performances(cond3));
    % x_new = (x - x_min)/(x_max - x_min) in [0,1]
    % x_new = (x - mu) / sigma in normal 0 mean and 1 stdev
  
    PV = measures_data{:,4};
    pmax = measures_data{:,5};

    alpha = best_models(:,3);
    beta = best_models(:,4);
    gamma = best_models(:,5);
    
    %% NORMALITY TESTS
    
    disp('Normality tests (Kolmogorov-Smirnov test)');
    [h] = kstest(PV);
    disp(['PV: ',num2str(~h)]);
    [h] = kstest(performances);
    disp(['performances: ',num2str(~h)]);
    [h] = kstest(alpha);
    disp(['alpha: ',num2str(~h)]);
    [h] = kstest(beta);
    disp(['beta: ',num2str(~h)]);
    [h] = kstest(gamma);
    disp(['gamma: ',num2str(~h)]);
    
    disp('Normality tests (Anderson-Darling test)');
    [h] = adtest(PV); 
    disp(['PV: ',num2str(~h)]);
    h = adtest(performances);
    disp(['performances: ',num2str(~h)]);
    h = adtest(alpha);
    disp(['alpha: ',num2str(~h)]);
    h = adtest(beta);
    disp(['beta: ',num2str(~h)]);
    h = adtest(gamma);
    disp(['gamma: ',num2str(~h)]);
    
    disp('Normality tests (Bera-Jarque test)');
    [h] = jbtest(PV); 
    disp(['PV: ',num2str(~h)]);
    h = jbtest(performances);
    disp(['performances: ',num2str(~h)]);
    h = jbtest(alpha);
    disp(['alpha: ',num2str(~h)]);
    h = jbtest(beta);
    disp(['beta: ',num2str(~h)]);
    h = jbtest(gamma);
    disp(['gamma: ',num2str(~h)]);
    
    %% hypothesis 2.1
    % Payoff variability vs Learning rate
    % 211 = hyp 2.1 condition 1
    disp('PV-alpha');
    [rho_21,pval_21] = corr(PV,alpha,'Type','Spearman');
    disp(['Hypothesis 2.1 - rho: ',num2str(rho_21),' - pval: ',num2str(pval_21)]);

    [rho_211,pval_211] = corr(PV(cond1),alpha(cond1),'Type','Spearman');
    [rho_212,pval_212] = corr(PV(cond2),alpha(cond2),'Type','Spearman');
    [rho_213,pval_213] = corr(PV(cond3),alpha(cond3),'Type','Spearman');
    
    disp(['Hyp: ',num2str(2),' Part: ',num2str(1),' Cond: ',num2str(1),' rho: ', num2str(rho_211),' pval: ',num2str(sum(pval_211))]);
    disp(['Hyp: ',num2str(2),' Part: ',num2str(1),' Cond: ',num2str(2),' rho: ', num2str(rho_212),' pval: ',num2str(sum(pval_212))]);
    disp(['Hyp: ',num2str(2),' Part: ',num2str(1),' Cond: ',num2str(3),' rho: ', num2str(rho_213),' pval: ',num2str(sum(pval_213))]);
    
    figure();
    title('Payoff Variability vs Learning rate');
    h1 = scatterhist(PV,alpha,'Group',conditions,'Kernel','on','NBins',[10,10],'LineStyle',{'-','-.',':'},...
    'LineWidth',[2,2,2],'Marker','+od','MarkerSize',[10,11,12]);
    hp = get(h1(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h1(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h1(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Payoff Variability ( \sigma )');
    ylabel('Learning rate ( \alpha )');
    set(gca,'FontSize',FONTSIZE);
    
    hold on;
    clr = get(h1(1),'colororder');
    bh = boxplot(h1(2),PV,conditions,'orientation','horizontal',...
         'label',{'','',''},'color',clr);
    
    for boxplot_part =1:size(bh,1)
        for box_plot_entity = 1:size(bh,2)
            set(bh(boxplot_part,box_plot_entity),'LineWidth',2);
        end
    end
    
    bh = boxplot(h1(3),alpha,conditions,'orientation','horizontal',...
         'label', {'','',''},'color',clr);
     
    for boxplot_part =1:size(bh,1)
        for box_plot_entity = 1:size(bh,2)
            set(bh(boxplot_part,box_plot_entity),'LineWidth',2);
        end
    end
    
    set(h1(2:3),'XTickLabel','');
    view(h1(3),[270,90]);  % Rotate the Y plot
    %axis(h(1),'auto');  % Sync axes
    ylim([-0.1 1.1])
    hold off;

    %% hypothesis 2.2
    % Payoff variability vs Greediness 
    disp('PV-beta');
    [rho_22,pval_22] = corr(PV,beta,'Type','Spearman');
    disp(['Hypothesis 2.2 - rho: ',num2str(rho_22),' - pval: ',num2str(pval_22)]);

    [rho_221,pval_221] = corr(PV(cond1),beta(cond1),'Type','Spearman');
    [rho_222,pval_222] = corr(PV(cond2),beta(cond2),'Type','Spearman');
    [rho_223,pval_223] = corr(PV(cond3),beta(cond3),'Type','Spearman');
    
    disp(['Hyp: ',num2str(2),' Part: ',num2str(2),' Cond: ',num2str(1),' rho: ', num2str(rho_221),' pval: ',num2str(sum(pval_221))]);
    disp(['Hyp: ',num2str(2),' Part: ',num2str(2),' Cond: ',num2str(2),' rho: ', num2str(rho_222),' pval: ',num2str(sum(pval_222))]);
    disp(['Hyp: ',num2str(2),' Part: ',num2str(2),' Cond: ',num2str(3),' rho: ', num2str(rho_223),' pval: ',num2str(sum(pval_223))]);
    
    figure();
    title('Payoff Variability vs Greediness');
    h2 = scatterhist(PV,beta,'Group',conditions,'NBins',[10,10],...
    'Marker','+od','MarkerSize',[10,11,12]);
    hp = get(h2(1),'children'); set(hp,'LineWidth',2);
    hp = get(h2(2),'children'); set(hp,'LineWidth',2);
    hp = get(h2(3),'children'); set(hp,'LineWidth',2);
    
    xlabel('Payoff Variability ( \sigma )');
    ylabel('Greediness ( \beta )');
    set(gca,'FontSize',FONTSIZE);
    
    hold on;
    clr = get(h2(1),'colororder');
    bh = boxplot(h2(2),PV,conditions,'orientation','horizontal',...
         'label',{'','',''},'color',clr);
    
    for boxplot_part =1:size(bh,1)
        for box_plot_entity = 1:size(bh,2)
            set(bh(boxplot_part,box_plot_entity),'LineWidth',2);
        end
    end
    
    bh = boxplot(h2(3),beta,conditions,'orientation','horizontal',...
         'label', {'','',''},'color',clr);
     
    for boxplot_part =1:size(bh,1)
        for box_plot_entity = 1:size(bh,2)
            set(bh(boxplot_part,box_plot_entity),'LineWidth',2);
        end
    end
    
    set(h2(2:3),'XTickLabel','');
    view(h2(3),[270,90]);  % Rotate the Y plot
    %axis(h(1),'auto');  % Sync axes
    ylim([-0.1 1.1])
    hold off;
    
    
    %TEMP scatterhist for cond 3 PV vs beta (only significant)
    h3 = scatterhist(PV(cond3),beta(cond3),'NBins',[10,10],'Marker','d','MarkerSize',10);
    hp = get(h3(1),'children'); set(hp,'LineWidth',2);
    hp = get(h3(2),'children'); set(hp,'LineWidth',2);
    hp = get(h3(3),'children'); set(hp,'LineWidth',2);
    
    xlabel('Payoff Variability ( \sigma )');
    ylabel('Greediness ( \beta )');
    set(gca,'FontSize',FONTSIZE);
    axis([20 40 -0.05 0.25]);
    hold off;
  
    %% hypothesis 3 accumulated outcomes
    % Performance vs Discount factor
    disp('performance-gamma');
    [rho_3,pval_3] = corr(performances,gamma,'Type','Spearman');
    disp(['Hypothesis 3 - rho: ',num2str(rho_3),' - pval: ',num2str(pval_3)]);

    disp('Final accumulated outcomes:');
    [rho_31,pval_31] = corr(performances(cond1),gamma(cond1),'Type','Spearman');
    [rho_32,pval_32] = corr(performances(cond2),gamma(cond2),'Type','Spearman');
    [rho_33,pval_33] = corr(performances(cond3),gamma(cond3),'Type','Spearman');
    
    disp(['Hyp: ',num2str(3),' Cond: ',num2str(1),' rho: ', num2str(rho_31),' pval: ',num2str(sum(pval_31))]);
    disp(['Hyp: ',num2str(3),' Cond: ',num2str(2),' rho: ', num2str(rho_32),' pval: ',num2str(sum(pval_32))]);
    disp(['Hyp: ',num2str(3),' Cond: ',num2str(3),' rho: ', num2str(rho_33),' pval: ',num2str(sum(pval_33))]);

    figure();
    h3 = scatterhist(performances(cond1),gamma(cond1),'Kernel','on','NBins',[10,10],'MarkerSize',10);
    hp = get(h3(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h3(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h3(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Cumulative rewards (\times 10^4)');
    xticks([5000 10000 15000]);
    xticklabels({'0.5','1.0','1.5'})
    ylabel('Discount factor ( \gamma )');
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])
    
    figure();
    h4 = scatterhist(performances(cond2),gamma(cond2),'Kernel','on','NBins',[10,10],'MarkerSize',10);
    hp = get(h4(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h4(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h4(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Cumulative rewards (\times 10^5)');
    ylabel('Discount factor ( \gamma )');
    xticks([245000 250000 255000 260000 265000]);
    xticklabels({'2.45','2.50','2.55','2.60','2.65'})
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])
    
    figure();
    h5 = scatterhist(performances(cond3),gamma(cond3),'Kernel','on','NBins',[10,10],'MarkerSize',10);
    hp = get(h5(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h5(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h5(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Cumulative rewards (\times 10^5)');
    ylabel('Discount factor ( \gamma )');
    xticks([255000 257000 259000]);
    xticklabels({'2.55','2.57','2.59'})
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])

    
    %% hypothesis 3 proportion of maximisation choices
    % Performance vs Discount factor
    disp('pmax-gamma');
    [rho_3,pval_3] = corr(pmax,gamma,'Type','Spearman');
    disp(['Hypothesis 3 - rho: ',num2str(rho_3),' - pval: ',num2str(pval_3)]);

    [rho_31,pval_31] = corr(pmax(cond1),gamma(cond1),'Type','Spearman');
    [rho_32,pval_32] = corr(pmax(cond2),gamma(cond2),'Type','Spearman');
    [rho_33,pval_33] = corr(pmax(cond3),gamma(cond3),'Type','Spearman');
    disp('pmax');
    disp(['Hyp: ',num2str(3),' Cond: ',num2str(1),' rho: ', num2str(rho_31),' pval: ',num2str(sum(pval_31))]);
    disp(['Hyp: ',num2str(3),' Cond: ',num2str(2),' rho: ', num2str(rho_32),' pval: ',num2str(sum(pval_32))]);
    disp(['Hyp: ',num2str(3),' Cond: ',num2str(3),' rho: ', num2str(rho_33),' pval: ',num2str(sum(pval_33))]);

    figure();
    h6 = scatterhist(pmax(cond1),gamma(cond1),'Kernel','on','NBins',[10,10],'MarkerSize',10);
    hp = get(h6(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h6(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h6(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Pmax');
    ylabel('Discount factor ( \gamma )');
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])
    
    figure();
    h7 = scatterhist(pmax(cond2),gamma(cond2),'Kernel','on','NBins',[10,10],'MarkerSize',10);
    hp = get(h7(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h7(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h7(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Pmax');
    ylabel('Discount factor ( \gamma )');
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])
    
    figure();
    h8 = scatterhist(pmax(cond3),gamma(cond3),'Kernel','on','NBins',[10,10],'MarkerSize',10);
    hp = get(h8(1),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h8(2),'children'); set(hp,'LineWidth',LINEWIDTH);
    hp = get(h8(3),'children'); set(hp,'LineWidth',LINEWIDTH);
    xlabel('Pmax');
    ylabel('Discount factor ( \gamma )');
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])
