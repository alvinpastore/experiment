pop_stats = 1;
subj_stats = 0;

close all;
%% static variables
hist_bins_A = 100;
hist_bins_B = 50;
LW = 2;
FS = 20;
num_subjects = 12;
choice_A = 1;
choice_B = 2;
choice_col = 4;
payoff_col = 5;

% colors
red = [215,25,28]/255;
orange = [253,174,97]/255;
green = [171,221,164]/255;
blue = [43,131,186]/255;
black = [0.5,0.5,0.5];

%% data gathering
data = csvread('../../data/BarronErev2003_Thaler_replication.csv');

% data separation into problems
data_problem_1 = data(data(:,1)==1,:);
data_problem_2 = data(data(:,1)==2,:);
data_problem_3 = data(data(:,1)==3,:);

% payoff data separation into choices
payoffs_p1A = data_problem_1(data_problem_1(:,4) == choice_A, payoff_col);
payoffs_p1B = data_problem_1(data_problem_1(:,4) == choice_B, payoff_col);
payoffs_p2A = data_problem_2(data_problem_2(:,4) == choice_A, payoff_col);
payoffs_p2B = data_problem_2(data_problem_2(:,4) == choice_B, payoff_col);
payoffs_p3A = data_problem_3(data_problem_3(:,4) == choice_A, payoff_col);
payoffs_p3B = data_problem_3(data_problem_3(:,4) == choice_B, payoff_col);

%% reward funcs
x = -2000:0.1:2000;

alpha = 0.6;
beta = 0.6;
lambda = 2;
yPT = (x.*(x>=0)).^alpha + (-lambda).*((-(x.*(x<0))).^beta);

omega =500;
new_range = 50;
y_tanh = new_range * (1 - exp(- x .* 1/omega)) ./ (1 + exp(- x .* 1/omega));


%% Population-wide statistics
if pop_stats
    % print statistics and histogram figures
    
    % Problem 1
    fprintf('problem 1 option A, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p1A),max(payoffs_p1A),mean(payoffs_p1A),std(payoffs_p1A));
    fprintf('problem 1 option B, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p1B),max(payoffs_p1B),mean(payoffs_p1B),std(payoffs_p1B));
    figure();
    h1 = histogram(payoffs_p1A,hist_bins_A,'EdgeColor','none');
    hold on;
    h2 = histogram(payoffs_p1B,hist_bins_B,'EdgeColor','none');
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
    fprintf('problem 2 option A, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p2A),max(payoffs_p2A),mean(payoffs_p2A),std(payoffs_p2A));
    fprintf('problem 2 option B, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p2B),max(payoffs_p2B),mean(payoffs_p2B),std(payoffs_p2B));
    figure();
    histogram(payoffs_p2A,hist_bins_A,'EdgeColor','none');
    hold on;
    histogram(payoffs_p2B,hist_bins_B,'EdgeColor','none');
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
    fprintf('problem 3 option A, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p3A),max(payoffs_p3A),mean(payoffs_p3A),std(payoffs_p3A));
    fprintf('problem 3 option B, min: %f, max: %f, mean: %f, std: %f \n',... 
    min(payoffs_p3B),max(payoffs_p3B),mean(payoffs_p3B),std(payoffs_p3B));
    figure();
    histogram(payoffs_p3A,hist_bins_A,'EdgeColor','none');
    hold on;
    histogram(payoffs_p3B,hist_bins_B,'EdgeColor','none');
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
end

%% Subjects statistics
if subj_stats
    figure();
    subplot(1,3,1);
    hold on;
    % data problem 1
    for subj_id = 1:num_subjects
        subj_data = data_problem_1(data_problem_1(:,2)==subj_id,:);
        pmax_part1 = sum(subj_data(1:100,choice_col)==choice_A)/100;
        pmax_part2 = sum(subj_data(101:200,choice_col)==choice_A)/100;
        fprintf('p1, subj: %d  pmax 1: %f  pmax 2: %f\n',subj_id,pmax_part1,pmax_part2);
        plot([1 2],[pmax_part1 pmax_part2],'LineWidth',LW);
        axis([0.75,2.25,0,1]);
        title('Problem 1')
    end
    hold off;


    subplot(1,3,2);
    hold on;
    % data problem 2
    for subj_id = 1:num_subjects
        subj_data = data_problem_2(data_problem_2(:,2)==subj_id,:);
        pmax_part1 = sum(subj_data(1:100,choice_col)==choice_A)/100;
        pmax_part2 = sum(subj_data(101:200,choice_col)==choice_A)/100;
        fprintf('p2, subj: %d  pmax 1: %f  pmax 2: %f\n',subj_id,pmax_part1,pmax_part2);
        plot([1 2],[pmax_part1 pmax_part2],'LineWidth',LW);
        axis([0.75,2.25,0,1]);
        title('Problem 2')
    end
    hold off;


    subplot(1,3,3);
    hold on;
    % data problem 3
    for subj_id = 1:num_subjects
        subj_data = data_problem_3(data_problem_3(:,2)==subj_id,:);
        pmax_part1 = sum(subj_data(1:100,choice_col)==choice_A)/100;
        pmax_part2 = sum(subj_data(101:200,choice_col)==choice_A)/100;
        fprintf('p3, subj: %d  pmax 1: %f  pmax 2: %f\n',subj_id,pmax_part1,pmax_part2);
        plot([1 2],[pmax_part1 pmax_part2],'LineWidth',LW);
        axis([0.75,2.25,0,1]);
        title('Problem 3')
    end
    hold off;
end
