function correlations_analysis(best_models)

    %% LOAD PV and subjects performances
    file_path = '../../results/';
    %file_name = 'results_test_greedy_random_generic__2017-03-02.csv'; %TEST
    file_name = 'measures_BarronErev2003_Thaler_replication.csv';
    fid = fopen([file_path,file_name]);
    format_spec = '%f %f %f %f';
    measures_data = textscan(fid, format_spec, 'delimiter', ',');
    fclose(fid);

    problem_id = measures_data{:,1};
    subj_id = measures_data{:,2};
    payoff_variabilities = measures_data{:,4};
    performances = measures_data{:,3};

    alpha = best_models(:,3);
    beta = best_models(:,4);
    gamma = best_models(:,5);

    % hypothesis 2.1
    % Payoff variability vs Learning rate
    % 211 = hyp 2.1 condition 1
    [rho_21,pval_21] = corr(payoff_variabilities,alpha,'Type','Spearman');
    [rho_211,pval_211] = corr(payoff_variabilities(1:12),alpha(1:12),'Type','Spearman');
    [rho_212,pval_212] = corr(payoff_variabilities(13:24),alpha(13:24),'Type','Spearman');
    [rho_213,pval_213] = corr(payoff_variabilities(25:36),alpha(25:36),'Type','Spearman');


    % hypothesis 2.2
    % Payoff variability vs Greediness 
    [rho_22,pval_22] = corr(payoff_variabilities,beta,'Type','Spearman');
    [rho_221,pval_221] = corr(payoff_variabilities(1:12),beta(1:12),'Type','Spearman');
    [rho_222,pval_222] = corr(payoff_variabilities(13:24),beta(13:24),'Type','Spearman');
    [rho_223,pval_223] = corr(payoff_variabilities(25:36),beta(25:36),'Type','Spearman');

    % hypothesis 3
    % Performance vs Discount factor
    [rho_3,pval_3] = corr(performances,gamma,'Type','Spearman');
    [rho_31,pval_31] = corr(performances(1:12),gamma(1:12),'Type','Spearman');
    [rho_32,pval_32] = corr(performances(13:24),gamma(13:24),'Type','Spearman');
    [rho_33,pval_33] = corr(performances(25:36),gamma(25:36),'Type','Spearman');


