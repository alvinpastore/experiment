function [Pmax, best_models] = msd_analysis()
    %close all;
    FIGURES = 0;

    %% CONSTANTS
    cond1 = 1:12;
    cond2 = 13:24;
    cond3 = 25:36;
    block_1_predicted = 4;
    block_2_predicted = 5;
    block_1_observed = 1:100;
    block_2_observed = 101:200;
    choice_col_observed = 4; 
    choice_HI = 1;
    choice_LO = 2;
    block_size = 100;
    n_subjects = 12;
    n_problems = 3;
    n_models = 8;
    MSD_col = 3;
    LINEWIDTH = 2;
    FONTSIZE = 25;
    MARKERSIZE = 10;
    %% LOAD DATA

    % predicted ------------------------------
    file_path = '../../results/';
    file_name = 'results_BarronErev2003_Thaler_replication__2017-04-29_MSD.csv';
    fid = fopen([file_path,file_name]);
    format_spec = '%f %f %f %f %f %f %f %f %s %s %s %*[^\n]';
    results_data = textscan(fid, format_spec, 'delimiter', ',');
    fclose(fid);
   

    % matrix of results with prob_id, subj_id, MSD, pmax1, pmax2, theta
    results = cell2mat(results_data(1:8));  
    % cell array of strings (it can be reduced to the first 15 and use an offset multiplication)
    configurations = horzcat(results_data{9:end}); 

    % observed ------------------------------
    data = csvread('../../data/BarronErev2003_Thaler_replication.csv');
    
    observed_pmax = zeros(n_subjects * n_problems,2);
    
    for prob_id = 1:n_problems
        data_problem = data(data(:,1)==prob_id,:);
        for subj_id = 1:n_subjects
            
            subj_data = data_problem(data_problem(:,2)==subj_id,:);
            
            pm1 = sum(subj_data(block_1_observed,choice_col_observed)==choice_HI)/100;
            pm2 = sum(subj_data(block_2_observed,choice_col_observed)==choice_HI)/100;
            line_idx = subj_id + (12*(prob_id-1));
            observed_pmax(line_idx,:) = [pm1,pm2];

        end
    end
        
    % MSD column values are wrong 
    % (averaged over many iterations instead of calculated once)
    % recalculate them correctly here
       
    for line_idx = 1:length(results)
        
        predicted = [results(line_idx,4), results(line_idx,5)];
        current_subj = (results(line_idx,2))+(12*(results(line_idx,1)));
        observed = [observed_pmax(current_subj,1), observed_pmax(current_subj,2)];
        results(line_idx,MSD_col) = 1/2*((predicted(1) - observed(1))^2+((predicted(2) - observed(2))^2));
    end
    % store only the best models according to MSD
    best_models = zeros(n_subjects*3,size(results,2));

    for subj_id = 1:n_subjects*3
        subj_begin = 1+(8*(subj_id-1));
        subj_end = 1+(8*subj_id-1);
        [~,best_idx] = min(results(subj_begin:subj_end,MSD_col));
        best_models(subj_id,:) = results(best_idx+subj_begin-1,:);
    end
    
    Pmax = [best_models(:,block_1_predicted),best_models(:,block_2_predicted)];
    if FIGURES
        figure()
        pmax1_cond1 = mean(Pmax(cond1,1));
        pmax2_cond1 = mean(Pmax(cond1,2));
        pmax1_cond2 = mean(Pmax(cond2,1));
        pmax2_cond2 = mean(Pmax(cond2,2));
        pmax1_cond3 = mean(Pmax(cond3,1));
        pmax2_cond3 = mean(Pmax(cond3,2));
        hold on
        plot([1 2],[pmax1_cond1 pmax2_cond1],'Color','k','Marker','d','MarkerFaceColor','k','LineWidth',LINEWIDTH,'MarkerSize',MARKERSIZE);
        plot([1 2],[pmax1_cond2 pmax2_cond2],'Color','k','Marker','s','MarkerFaceColor','k','LineWidth',LINEWIDTH,'MarkerSize',MARKERSIZE);
        plot([1 2],[pmax1_cond3 pmax2_cond3],'Color','k','Marker','^','MarkerFaceColor','k','LineWidth',LINEWIDTH,'MarkerSize',MARKERSIZE);
        axis([0.85 2.15 0 1]);
        hold off

        figure()
        pmax1_cond1 = mean(results(1:96,4));
        pmax2_cond1 = mean(results(1:96,5));
        pmax1_cond2 = mean(results(97:192,4));
        pmax2_cond2 = mean(results(97:192,5));
        pmax1_cond3 = mean(results(193:288,4));
        pmax2_cond3 = mean(results(193:288,5));
        hold on
        plot([1 2],[pmax1_cond1 pmax2_cond1],'Color','k','Marker','d','MarkerFaceColor','k','LineWidth',LINEWIDTH,'MarkerSize',MARKERSIZE);
        plot([1 2],[pmax1_cond2 pmax2_cond2],'Color','k','Marker','s','MarkerFaceColor','k','LineWidth',LINEWIDTH,'MarkerSize',MARKERSIZE);
        plot([1 2],[pmax1_cond3 pmax2_cond3],'Color','k','Marker','^','MarkerFaceColor','k','LineWidth',LINEWIDTH,'MarkerSize',MARKERSIZE);
        axis([0.85 2.15 0 1]);
        hold off
    end
    
    %% observed ------------------------------
    data = csvread('../../data/BarronErev2003_Thaler_replication.csv');

    % data separation into problems
    data_problem_1 = data(data(:,1)==1,:);
    data_problem_2 = data(data(:,1)==2,:);
    data_problem_3 = data(data(:,1)==3,:);

    observed_Pmax = zeros(n_subjects,2); % pmax1 and 2 in col 1 and 2

    % pmax estimation of observed choices
    for subj_id = 1:n_subjects

        p1_subj_data = data_problem_1(data_problem_1(:,2)==subj_id,:);
        p2_subj_data = data_problem_2(data_problem_2(:,2)==subj_id,:);
        p3_subj_data = data_problem_3(data_problem_3(:,2)==subj_id,:);

        observed_Pmax(subj_id,1) = sum(p1_subj_data(block_1_observed,choice_col_observed)==choice_HI)/block_size;
        observed_Pmax(subj_id+(n_subjects),1) = sum(p2_subj_data(block_1_observed,choice_col_observed)==choice_HI)/block_size;
        observed_Pmax(subj_id+(n_subjects*2),1) = sum(p3_subj_data(block_1_observed,choice_col_observed)==choice_HI)/block_size;

        observed_Pmax(subj_id,2) = sum(p1_subj_data(block_2_observed,choice_col_observed)==choice_HI)/block_size;
        observed_Pmax(subj_id+(n_subjects),2) = sum(p2_subj_data(block_2_observed,choice_col_observed)==choice_HI)/block_size;
        observed_Pmax(subj_id+(n_subjects*2),2) = sum(p3_subj_data(block_2_observed,choice_col_observed)==choice_HI)/block_size;
    end

    if FIGURES
        %% FIGURES
        % plots barcharts (grouped histograms)
        edges = [1,3,5,7,9]/10;
        figure();
        h1 = histogram(observed_Pmax(cond1,2),edges);
        xlim([0,1]); title='Cond 1';
        figure();
        h2 = histogram(observed_Pmax(cond2,2),edges);
        xlim([0,1]); title='Cond 2';
        figure();
        h3 = histogram(observed_Pmax(cond3,2),edges);
        xlim([0,1]); title='Cond 3';

        % h1.Normalization = 'count';
        % h1.BinWidth = 0.05;
        % 
        % h2.Normalization = 'count';
        % h2.BinWidth = 0.05;
        % 
        % h3.Normalization = 'count';
        % h3.BinWidth = 0.05;

        %clearvars -except results configurations
    end

end
