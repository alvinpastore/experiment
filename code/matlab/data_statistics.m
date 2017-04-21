pop_stats = 0;
subj_stats = 1;

close all;
%% static variables
hist_bins_HI = 100;
hist_bins_LO = 50;
LW = 4;
FS = 25;
num_subjects = 12;
choice_HI = 1;
choice_LO = 2;
choice_col = 4;
payoff_col = 5;
block_1 = 1:50;
block_2 = 51:100;
block_3 = 101:150;
block_4 = 151:200;

% colors
% red = [215,25,28]/255;
% orange = [253,174,97]/255;
% green = [171,221,164]/255;
% blue = [43,131,186]/255;
% black = [0.5,0.5,0.5];
red = [235, 49, 20]/255;
orange = [235, 88, 20]/255;
mustard = [235, 156, 20]/255;
yellow = [235, 217, 20]/255;
green1 = [175, 222, 33]/255;
green2 = [69, 210, 45]/255;
tale = [28, 227, 154]/255;
blue1 = [28, 227, 207]/255;
%blue2 = [28, 210, 227]/255;
blue3 = [28, 161, 227]/255;
%blue4 = [34, 90, 221]/255;
purple = [144, 117, 219]/255;
lavander = [184, 117, 219]/255;
pink1 = [219, 117, 219]/255;
pink2 = [219, 117, 155]/255;

colors_palette = [red; orange; mustard; yellow; green1; green2; tale; blue1; blue3; purple; lavander; pink1];

%% data gathering
data = csvread('../../data/BarronErev2003_Thaler_replication.csv');

% data separation into problems
data_problem_1 = data(data(:,1)==1,:);
data_problem_2 = data(data(:,1)==2,:);
data_problem_3 = data(data(:,1)==3,:);

% payoff data separation into choices
payoffs_p1HI = data_problem_1(data_problem_1(:,4) == choice_HI, payoff_col);
payoffs_p1LO = data_problem_1(data_problem_1(:,4) == choice_LO, payoff_col);
payoffs_p2HI = data_problem_2(data_problem_2(:,4) == choice_HI, payoff_col);
payoffs_p2LO = data_problem_2(data_problem_2(:,4) == choice_LO, payoff_col);
payoffs_p3HI = data_problem_3(data_problem_3(:,4) == choice_HI, payoff_col);
payoffs_p3LO = data_problem_3(data_problem_3(:,4) == choice_LO, payoff_col);

%% reward funcs
x = -2000:0.1:2000;

alpha = 0.88;
beta = 0.88;
lambda = 2.25;
yPT = (x.*(x>=0)).^alpha + (-lambda).*((-(x.*(x<0))).^beta);

omega =500;
new_range = 50;
y_tanh = new_range * (1 - exp(- x .* 1/omega)) ./ (1 + exp(- x .* 1/omega));


%% Population-wide statistics
if pop_stats
    % print statistics and histogram figures
    
    % Problem 1
    fprintf('problem 1 option Hi, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p1HI),max(payoffs_p1HI),mean(payoffs_p1HI),std(payoffs_p1HI));
    fprintf('problem 1 option Lo, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p1LO),max(payoffs_p1LO),mean(payoffs_p1LO),std(payoffs_p1LO));
    figure();
    h1 = histogram(payoffs_p1HI,hist_bins_HI,'EdgeColor','none');
    hold on;
    h2 = histogram(payoffs_p1LO,hist_bins_LO,'EdgeColor','none');
    ylabel('Outcomes frequency')
    title('Problem 1');
    xlabel('Original outcome');
    yyaxis right
    ax = gca;
    ax.YColor = 'Black'; 
    %plot(x,x,'r-','LineWidth',LW); identity is too wide in the y axis
    plot(x,yPT+new_range,'Color',blue,'LineStyle','-','LineWidth',LW);
    plot(x,y_tanh+new_range,'Color',green,'LineStyle','-','LineWidth',LW);
    ylabel('Reward functions output')
    xlim([-800 800])
    xticks([-750 -500 -250 0 250 500 750]);
    %xlim([min(payoffs_p1A) max(payoffs_p1A)]);
    set(gca,'FontSize',FS);
    hold off;

    % Problem 2
    fprintf('problem 2 option Hi, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p2HI),max(payoffs_p2HI),mean(payoffs_p2HI),std(payoffs_p2HI));
    fprintf('problem 2 option Lo, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p2LO),max(payoffs_p2LO),mean(payoffs_p2LO),std(payoffs_p2LO));
    figure();
    histogram(payoffs_p2HI,hist_bins_HI,'EdgeColor','none');
    hold on;
    histogram(payoffs_p2LO,hist_bins_LO,'EdgeColor','none');
    ylabel('Outcomes frequency')
    title('Problem 2');
    xlabel('Original outcome');
    yyaxis right
    ax = gca;
    ax.YColor = 'Black'; 
    %plot(x,x,'r-','LineWidth',LW); identity is too wide in the y axis
    plot(x,yPT+new_range,'Color',blue,'LineStyle','-','LineWidth',LW);
    plot(x,y_tanh+new_range,'Color',green,'LineStyle','-','LineWidth',LW);
    ylabel('Reward functions output')
    xlim([400 2000]);
    xticks([600 1000 1400 1800]);
    set(gca,'FontSize',FS);
    hold off;

    % Problem 3
    fprintf('problem 3 option Hi, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p3HI),max(payoffs_p3HI),mean(payoffs_p3HI),std(payoffs_p3HI));
    fprintf('problem 3 option Lo, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p3LO),max(payoffs_p3LO),mean(payoffs_p3LO),std(payoffs_p3LO));
    figure();
    histogram(payoffs_p3HI,hist_bins_HI,'EdgeColor','none');
    hold on;
    histogram(payoffs_p3LO,hist_bins_LO,'EdgeColor','none');
    ylabel('Outcomes frequency')
    title('Problem 3');
    xlabel('Original outcome');
    yyaxis right
    ax = gca;
    ax.YColor = 'Black'; 
    %plot(x,x,'r-','LineWidth',LW); identity is too wide in the y axis
    plot(x,yPT+new_range,'Color',blue,'LineStyle','-','LineWidth',LW);
    plot(x,y_tanh+new_range,'Color',green,'LineStyle','-','LineWidth',LW);
    xlim([1150 1350]);
    ylabel('Reward functions output')
    %yticks([-200 -100 0 100 200])
    xticks([1200 1250 1300])
    set(gca,'FontSize',FS);
    hold off;
    
    %% subplots 
    % underlying distributions
    figure()
    x = [-1000:.01:1000];
    y = [0:.01:1000];
    lo = normpdf(y,25,17.7);
    hi = normpdf(x,100,354);
    subplot(1,3,1);
    hold on
    title('Condition 1');
    plot(y,lo,'LineWidth',LINEWIDTH)
    plot(x,hi,'LineWidth',LINEWIDTH)
    line([0 0], get(gca, 'ylim'),'Color','k','LineWidth',LINEWIDTH-1);
    set(gca,'FontSize',FONTSIZE);
    ylabel('PDF');
    axis([-400 800 0 0.025])
    hold off

    x = [100:1:2000];
    lo = normpdf(x,1225,17.7);
    hi = normpdf(x,1300,354);
    subplot(1,3,2);
    hold on
    title('Condition 2');
    plot(x,lo,'LineWidth',LINEWIDTH)
    plot(x,hi,'LineWidth',LINEWIDTH)
    set(gca,'FontSize',FONTSIZE);
    axis([800 2000 0 0.025])
    legend({'Option Low','Option High'})
    xlabel('Payoff value')
    hold off

    lo = normpdf(x,1225,17.7);
    hi = normpdf(x,1300,17.7);
    subplot(1,3,3);
    hold on
    title('Condition 3');
    plot(x,lo,'LineWidth',LINEWIDTH)
    plot(x,hi,'LineWidth',LINEWIDTH)
    set(gca,'FontSize',FONTSIZE);
    axis([1100 1500 0 0.025])
    hold off

    % observed distributions
    figure(); % <- remove to overlap the two
    subplot(1,3,1);
    hold on
    title('Condition 1');
    h2 = histogram(payoffs_p1LO,hist_bins_LO,'EdgeColor','none');
    h1 = histogram(payoffs_p1HI,hist_bins_HI,'EdgeColor','none');
    line([0 0], get(gca, 'ylim'),'Color','k','LineWidth',LINEWIDTH-2);
    set(gca,'FontSize',FONTSIZE);
    ylabel('Frequency');
    xlim([-400 800])
    hold off

    x = [100:1:2000];
    subplot(1,3,2);
    hold on
    title('Condition 2');
    histogram(payoffs_p2LO,hist_bins_LO,'EdgeColor','none');
    histogram(payoffs_p2HI,hist_bins_HI,'EdgeColor','none');
    set(gca,'FontSize',FONTSIZE);
    xlim([800 2000])
    legend({'Option Low','Option High'})
    xlabel('Payoff value')
    hold off

    subplot(1,3,3);
    hold on
    title('Condition 3');
    histogram(payoffs_p3LO,hist_bins_LO,'EdgeColor','none');
    histogram(payoffs_p3HI,hist_bins_HI,'EdgeColor','none');
    set(gca,'FontSize',FONTSIZE);
    xlim([1100 1500])
    hold off
    
end

%% Subjects statistics
%% PMAX SUBPLOTS
if subj_stats
    figure();
    FW = 20;
    subplot(1,3,1);
    hold on;
    % data problem 1
    for subj_id = 1:num_subjects
        subj_data = data_problem_1(data_problem_1(:,2)==subj_id,:);
        payoffs_part1 = sum(subj_data(block_1,choice_col)==choice_HI)/50;
        payoffs_part2 = sum(subj_data(block_2,choice_col)==choice_HI)/50;
        payoffs_part3 = sum(subj_data(block_3,choice_col)==choice_HI)/50;
        payoffs_part4 = sum(subj_data(block_4,choice_col)==choice_HI)/50;
        fprintf('p1, subj: %d  pmax 1: %f  2: %f  3: %f  4: %f\n',subj_id,payoffs_part1,payoffs_part2,payoffs_part3,payoffs_part4);
        plot([1 2 3 4],[payoffs_part1 payoffs_part2 payoffs_part3 payoffs_part4],'LineWidth',LW,'Color',colors_palette(subj_id,:));
        axis([0.75,4.25,0,1]);
        title('Condition 1')
        set(gca,'FontSize',FW)
        ylabel('PMax')
        xticks([1,2,3,4])
        xticklabels({'50','100','150','200'})
    end
    hold off;


    subplot(1,3,2);
    hold on;
    % data problem 2
    for subj_id = 1:num_subjects
        subj_data = data_problem_2(data_problem_2(:,2)==subj_id,:);
        payoffs_part1 = sum(subj_data(block_1,choice_col)==choice_HI)/50;
        payoffs_part2 = sum(subj_data(block_2,choice_col)==choice_HI)/50;
        payoffs_part3 = sum(subj_data(block_3,choice_col)==choice_HI)/50;
        payoffs_part4 = sum(subj_data(block_4,choice_col)==choice_HI)/50;
        fprintf('p2, subj: %d  pmax 1: %f  2: %f  3: %f  4: %f\n',subj_id,payoffs_part1,payoffs_part2,payoffs_part3,payoffs_part4);
        plot([1 2 3 4],[payoffs_part1 payoffs_part2 payoffs_part3 payoffs_part4],'LineWidth',LW,'Color',colors_palette(subj_id,:));
        axis([0.75,4.25,0,1]);
        title('Condition 2')
        set(gca,'FontSize',FW)
        xlabel('Trials')
        xticks([1,2,3,4])
        xticklabels({'50','100','150','200'})
    end
    hold off;


    subplot(1,3,3);
    hold on;
    % data problem 3
    for subj_id = 1:num_subjects
        subj_data = data_problem_3(data_problem_3(:,2)==subj_id,:);
        payoffs_part1 = sum(subj_data(block_1,choice_col)==choice_HI)/50;
        payoffs_part2 = sum(subj_data(block_2,choice_col)==choice_HI)/50;
        payoffs_part3 = sum(subj_data(block_3,choice_col)==choice_HI)/50;
        payoffs_part4 = sum(subj_data(block_4,choice_col)==choice_HI)/50;
        fprintf('p3, subj: %d  pmax 1: %f  2: %f  3: %f  4: %f\n',subj_id,payoffs_part1,payoffs_part2,payoffs_part3,payoffs_part4);
        plot([1 2 3 4],[payoffs_part1 payoffs_part2 payoffs_part3 payoffs_part4],'LineWidth',LW,'Color',colors_palette(subj_id,:));
        axis([0.75,4.25,0,1]);
        title('Condition 3')
        set(gca,'FontSize',FW)
        xticks([1,2,3,4])
        xticklabels({'50','100','150','200'})
    end
    legend({'1','2','3','4','5','6','7','8','9','10','11','12'},'Location','SouthEast');
    hold off;
    
    %% PAYOFFS SUBPLOTS
    figure();
    FW = 20;
    subplot(1,3,1);
    hold on;
    % data problem 1
    for subj_id = 1:num_subjects
        subj_data = data_problem_1(data_problem_1(:,2)==subj_id,:);
        payoffs_part1 = sum(subj_data(block_1,payoff_col))/50;
        payoffs_part2 = sum(subj_data(block_2,payoff_col))/50;
        payoffs_part3 = sum(subj_data(block_3,payoff_col))/50;
        payoffs_part4 = sum(subj_data(block_4,payoff_col))/50;
        fprintf('p1, subj: %d  payoffs 1: %f  2: %f  3: %f  4: %f\n',subj_id,payoffs_part1,payoffs_part2,payoffs_part3,payoffs_part4);
        plot([1 2 3 4],[payoffs_part1 payoffs_part2 payoffs_part3 payoffs_part4],'LineWidth',LW-2,'Color',colors_palette(subj_id,:));
        xlim([0.75,4.25]);
        title('Condition 1')
        set(gca,'FontSize',FW)
        ylabel('Average Payoff')
        xticks([1,2,3,4])
        xticklabels({'50','100','150','200'})
    end
    hold off;


    subplot(1,3,2);
    hold on;
    % data problem 2
    for subj_id = 1:num_subjects
        subj_data = data_problem_2(data_problem_2(:,2)==subj_id,:);
        payoffs_part1 = sum(subj_data(block_1,payoff_col))/50;
        payoffs_part2 = sum(subj_data(block_2,payoff_col))/50;
        payoffs_part3 = sum(subj_data(block_3,payoff_col))/50;
        payoffs_part4 = sum(subj_data(block_4,payoff_col))/50;
        fprintf('p2, subj: %d  payoffs 1: %f  2: %f  3: %f  4: %f\n',subj_id,payoffs_part1,payoffs_part2,payoffs_part3,payoffs_part4);
        plot([1 2 3 4],[payoffs_part1 payoffs_part2 payoffs_part3 payoffs_part4],'LineWidth',LW-2,'Color',colors_palette(subj_id,:));
        xlim([0.75,4.25]);
        title('Condition 2')
        set(gca,'FontSize',FW)
        xlabel('Trials')
        xticks([1,2,3,4])
        xticklabels({'50','100','150','200'})
    end
    hold off;


    subplot(1,3,3);
    hold on;
    % data problem 3
    for subj_id = 1:num_subjects
        subj_data = data_problem_3(data_problem_3(:,2)==subj_id,:);
        payoffs_part1 = sum(subj_data(block_1,payoff_col))/50;
        payoffs_part2 = sum(subj_data(block_2,payoff_col))/50;
        payoffs_part3 = sum(subj_data(block_3,payoff_col))/50;
        payoffs_part4 = sum(subj_data(block_4,payoff_col))/50;
        fprintf('p3, subj: %d  payoffs 1: %f  2: %f  3: %f  4: %f\n',subj_id,payoffs_part1,payoffs_part2,payoffs_part3,payoffs_part4);
        plot([1 2 3 4],[payoffs_part1 payoffs_part2 payoffs_part3 payoffs_part4],'LineWidth',LW-2,'Color',colors_palette(subj_id,:));
        xlim([0.75,4.25]);
        title('Condition 3')
        set(gca,'FontSize',FW)
        xticks([1,2,3,4])
        xticklabels({'50','100','150','200'})
    end
    legend({'1','2','3','4','5','6','7','8','9','10','11','12'},'Location','SouthEast');
    hold off;
    
end
