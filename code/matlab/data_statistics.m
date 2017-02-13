close all;
%% static variables
hist_bins = 20;
LW = 2;
num_subjects = 12;
choice_A = 1;
choice_B = 2;
choice_col = 4;
payoff_col = 5;

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

%% Population-wide statistics

% print statistics and histogram figures
fprintf('problem 1 option A, min: %f, max: %f, mean: %f, std: %f \n',... 
min(payoffs_p1A),max(payoffs_p1A),mean(payoffs_p1A),std(payoffs_p1A));
fprintf('problem 1 option B, min: %f, max: %f, mean: %f, std: %f \n',... 
min(payoffs_p1B),max(payoffs_p1B),mean(payoffs_p1B),std(payoffs_p1B));
subplot(2,3,1);
hist(payoffs_p1A,hist_bins);
ylabel('Dist. outcomes option A')
subplot(2,3,4);
hist(payoffs_p1B,hist_bins);
ylabel('Dist. outcomes option B')
xlabel('Problem 1');

fprintf('problem 2 option A, min: %f, max: %f, mean: %f, std: %f \n',... 
min(payoffs_p2A),max(payoffs_p2A),mean(payoffs_p2A),std(payoffs_p2A));
fprintf('problem 2 option B, min: %f, max: %f, mean: %f, std: %f \n',... 
min(payoffs_p2B),max(payoffs_p2B),mean(payoffs_p2B),std(payoffs_p2B));
subplot(2,3,2);
hist(payoffs_p2A,hist_bins);
subplot(2,3,5);
hist(payoffs_p2B,hist_bins);
xlabel('Problem 2');

fprintf('problem 3 option A, min: %f, max: %f, mean: %f, std: %f \n',... 
min(payoffs_p3A),max(payoffs_p3A),mean(payoffs_p3A),std(payoffs_p3A));
fprintf('problem 3 option B, min: %f, max: %f, mean: %f, std: %f \n',... 
min(payoffs_p3B),max(payoffs_p3B),mean(payoffs_p3B),std(payoffs_p3B));
subplot(2,3,3);
hist(payoffs_p3A,hist_bins);
subplot(2,3,6);
hist(payoffs_p3B,hist_bins);
xlabel('Problem 3');



%% Subjects statistics
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

