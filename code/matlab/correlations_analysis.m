function correlations_analysis(best_models)
    
    close all;
    
    % CONSTANTS
    % figures constants
    MARKERSIZE = 30;
    LINEWIDTH = 3;
    FONTSIZE = 20;
    red = [215,25,28]/255;
    orange = [253,174,97]/255;
    green = [171,221,164]/255;
    blue = [43,131,186]/255;
    black = [0.5,0.5,0.5];
    
    % indexing constants
    cond1 = 1:12;
    cond2 = 13:24;
    cond3 = 25:36;
    
    %% LOAD PV and subjects performances
    file_path = '../../results/';
    %file_name = 'results_test_greedy_random_generic__2017-03-02.csv'; %TEST
    file_name = 'measures_BarronErev2003_Thaler_replication.csv';
    fid = fopen([file_path,file_name]);
    format_spec = '%f %f %f %f';
    measures_data = textscan(fid, format_spec, 'delimiter', ',');
    fclose(fid);

%     problem_id = measures_data{:,1};
%     subj_id = measures_data{:,2};
    
    original_PV = measures_data{:,4};
    % normalise each condition payoff variabilities on the max PV
    % experienced in that subgroup
    PV = zeros(36,1);
    PV(cond1) = original_PV(cond1)/max(original_PV(cond1));  % maybe normalise on the std dev of the conditions (avg of the two)
    PV(cond2) = original_PV(cond2)/max(original_PV(cond2));
    PV(cond3) = original_PV(cond3)/max(original_PV(cond3));
    
    original_performances = measures_data{:,3};
    performances = zeros(36,1);
    % normalise each condition performance on the max performance
    % experienced in that subgroup
    performances(cond1) = original_performances(cond1)/max(original_performances(cond1));
    performances(cond2) = original_performances(cond2)/max(original_performances(cond2));
    performances(cond3) = original_performances(cond3)/max(original_performances(cond3));
    
    alpha = best_models(:,3);
    beta = best_models(:,4);
    gamma = best_models(:,5);
    
    %% NORMALITY TESTS
    disp('Normality tests (Kolmogorov-Smirnov test)');
    [h,p] = kstest(PV); [ho,p] = kstest(original_PV);
    disp(['PV: ',num2str(~h),' original_PV: ',num2str(~ho)]);
    [h,p] = kstest(performances);
    disp(['performances: ',num2str(~h)]);
    [h,p] = kstest(alpha);
    disp(['alpha: ',num2str(~h)]);
    [h,p] = kstest(beta);
    disp(['beta: ',num2str(~h)]);
    [h,p] = kstest(gamma);
    disp(['gamma: ',num2str(~h)]);
    
    disp('Normality tests (Anderson-Darling test)');
    [h,p] = adtest(PV); [ho,p] = adtest(original_PV);
    disp(['PV: ',num2str(~h),' original_PV: ',num2str(~ho)]);
    h = adtest(performances);
    disp(['performances: ',num2str(~h)]);
    h = adtest(alpha);
    disp(['alpha: ',num2str(~h)]);
    h = adtest(beta);
    disp(['beta: ',num2str(~h)]);
    h = adtest(gamma);
    disp(['gamma: ',num2str(~h)]);
    
    disp('Normality tests (Bera-Jarque test)');
    [h,p] = jbtest(PV); [ho,p] = jbtest(original_PV);
    disp(['PV: ',num2str(~h),' original_PV: ',num2str(~ho)]);
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
    [rho_21,pval_21] = corr(PV,alpha,'Type','Spearman');
    disp(['Hypothesis 2.1 - rho: ',num2str(rho_21),' - pval: ',num2str(pval_21)]);
%     [rho_211,pval_211] = corr(PV(cond1),alpha(cond1),'Type','Spearman');
%     [rho_212,pval_212] = corr(PV(cond2),alpha(cond2),'Type','Spearman');
%     [rho_213,pval_213] = corr(PV(cond3),alpha(cond3),'Type','Spearman');
%     disp(['Hyp: ',num2str(2),' Part: ',num2str(1),' Cond: ',num2str(1),' rho: ', num2str(rho_211),' pval: ',num2str(sum(pval_211))]);
%     disp(['Hyp: ',num2str(2),' Part: ',num2str(1),' Cond: ',num2str(2),' rho: ', num2str(rho_212),' pval: ',num2str(sum(pval_212))]);
%     disp(['Hyp: ',num2str(2),' Part: ',num2str(1),' Cond: ',num2str(3),' rho: ', num2str(rho_213),' pval: ',num2str(sum(pval_213))]);
    
    figure();
    title('PV vs Learning rate');
    scatterhist(PV,alpha,'NBins',[10,10],'Marker','+','MarkerSize',10);
    xlabel('Payoff Variability (Std Dev)');
    ylabel('Learning rate (alpha)');
    set(gca,'FontSize',FONTSIZE);
%     axis([0 350 -0.1 1.1])
    
    % SAME FIGURE WITH BOXPLOTS INSTEAD OF HISTOGRAMS
%     figure();
%     h = scatterhist(PV,alpha,'NBins',[10,10],'Marker','+','MarkerSize',10);
%     hold on;
%     clr = get(h(1),'colororder');
%     boxplot(h(2),PV,'orientation','horizontal');
%     boxplot(h(3),alpha,'orientation','horizontal');
%     set(h(2:3),'XTickLabel','');
%     view(h(3),[270,90]);  % Rotate the Y plot
%     axis(h(1),'auto');  % Sync axes
%     axis([0 350 -0.1 1.1])
%     xlabel('Payoff Variability (Std Dev)');
%     ylabel('Learning rate (alpha)');
%     set(gca,'FontSize',FONTSIZE);
%     hold off;
    
% %     figure();
% %     subplot(1,3,1);
% %     scatter(PV(cond1)/max(PV(cond1)),alpha(cond1),MARKERSIZE,'filled');
% %     lh = lsline; lh.LineWidth = LINEWIDTH; lh.Color = blue;
% %     ylim([-0.05 1.05])
% %     
% %     subplot(1,3,2);
% %     scatter(PV(cond2)/max(PV(cond2)),alpha(cond2),MARKERSIZE,'filled');
% %     lh = lsline; lh.LineWidth = LINEWIDTH; lh.Color = blue;
% %     ylim([-0.05 1.05])
% %     
% %     subplot(1,3,3);
% %     scatter(PV(cond3)/max(PV(cond3)),alpha(cond3),MARKERSIZE,'filled');
% %     lh = lsline; lh.LineWidth = LINEWIDTH; lh.Color = blue;
% %     ylim([-0.05 1.05])
    
%     figure();
%     scatterhist(PV,alpha,'NBins',[10,10]);
%     figure();
%     scatterhist(PV(1:12),alpha(1:12),'NBins',[10,10]);
%     figure();
%     scatterhist(PV(13:24),alpha(13:24),'NBins',[10,10]);
%     figure();
%     scatterhist(PV(25:36),alpha(25:36),'NBins',[10,10]);
%     
    %% hypothesis 2.2
    % Payoff variability vs Greediness 
    [rho_22,pval_22] = corr(PV,beta,'Type','Spearman');
    disp(['Hypothesis 2.2 - rho: ',num2str(rho_22),' - pval: ',num2str(pval_22)]);
%     [rho_221,pval_221] = corr(PV(cond1),beta(cond1),'Type','Spearman');
%     [rho_222,pval_222] = corr(PV(cond2),beta(cond2),'Type','Spearman');
%     [rho_223,pval_223] = corr(PV(cond3),beta(cond3),'Type','Spearman');
%     disp(['Hyp: ',num2str(2),' Part: ',num2str(2),' Cond: ',num2str(1),' rho: ', num2str(rho_221),' pval: ',num2str(sum(pval_221))]);
%     disp(['Hyp: ',num2str(2),' Part: ',num2str(2),' Cond: ',num2str(2),' rho: ', num2str(rho_222),' pval: ',num2str(sum(pval_222))]);
%     disp(['Hyp: ',num2str(2),' Part: ',num2str(2),' Cond: ',num2str(3),' rho: ', num2str(rho_223),' pval: ',num2str(sum(pval_223))]);
    
    figure();
    title('PV vs Greediness');
    scatterhist(PV,beta,'NBins',[10,10],'Marker','+','MarkerSize',10);
    xlabel('Payoff Variability (Std Dev)');
    ylabel('Greediness (beta)');
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])
    
    %% hypothesis 3
    % Performance vs Discount factor
    [rho_3,pval_3] = corr(performances,gamma,'Type','Spearman');
    disp(['Hypothesis 3 - rho: ',num2str(rho_3),' - pval: ',num2str(pval_3)]);
%     [rho_31,pval_31] = corr(performances(cond1),gamma(cond1),'Type','Spearman');
%     [rho_32,pval_32] = corr(performances(cond2),gamma(cond2),'Type','Spearman');
%     [rho_33,pval_33] = corr(performances(cond3),gamma(cond3),'Type','Spearman');
%     disp(['Hyp: ',num2str(3),' Cond: ',num2str(1),' rho: ', num2str(rho_31),' pval: ',num2str(sum(pval_31))]);
%     disp(['Hyp: ',num2str(3),' Cond: ',num2str(2),' rho: ', num2str(rho_32),' pval: ',num2str(sum(pval_32))]);
%     disp(['Hyp: ',num2str(3),' Cond: ',num2str(3),' rho: ', num2str(rho_33),' pval: ',num2str(sum(pval_33))]);

    figure();
    title('Performance vs Discount factor');
    scatterhist(performances,gamma,'NBins',[10,10],'Marker','+','MarkerSize',10);
    xlabel('Performances (Cumulative rewards)');
    ylabel('Discount factor (gamma)');
    set(gca,'FontSize',FONTSIZE);
    ylim([-0.1 1.1])

%     figure();
%     title('H3, cond1');
%     scatterhist(performances(cond1),gamma(cond1),'NBins',[10,10],'Marker','+','MarkerSize',10);
%     xlabel('Performances (Cumulative rewards)');
%     ylabel('Discount factor (gamma)');
%     set(gca,'FontSize',FONTSIZE);
% 
%     figure();
%     title('H3, cond2');
%     scatterhist(performances(cond2),gamma(cond2),'NBins',[10,10],'Marker','+','MarkerSize',10);
%     xlabel('Performances (Cumulative rewards)');
%     ylabel('Discount factor (gamma)');
%     set(gca,'FontSize',FONTSIZE);
% 
%     figure();
%     title('H3, cond3');
%     scatterhist(performances(cond3),gamma(cond3),'NBins',[10,10],'Marker','+','MarkerSize',10);
%     xlabel('Performances (Cumulative rewards)');
%     ylabel('Discount factor (gamma)');
%     set(gca,'FontSize',FONTSIZE);
%     ylim([-0.1 1.1])
