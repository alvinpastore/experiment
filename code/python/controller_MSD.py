from __future__ import division

import itertools
import time
import datetime
import sys

from numpy.random import normal

from Model import Model
from Model import constants
from DataReader import DataReader


def model_fit(*args):

    params, transactions, configuration = args

    MSD = 0

    observed_choices = zip(*transactions)[0]
    half_size = int(len(observed_choices) / 2)
    pmax_observed1 = 1 - (sum(observed_choices[:half_size]) / half_size)
    pmax_observed2 = 1 - (sum(observed_choices[half_size:]) / half_size)

    for iteration in xrange(n_iterations):

        # generate a model with theta and configuration
        model = Model.Model(params, *configuration)

        simulated_values = {'choices': [], 'payoffs': []}

        for trial_i in xrange(len(transactions)):
            action = model.pick_action()
            outcome = get_payoff(action)
            reward = model.get_reward(outcome)
            model.update_action_values(reward, action)

            # store choice and payoff
            simulated_values['choices'].append(action)
            simulated_values['payoffs'].append(outcome)

        model.store_choices(simulated_values)

        # "one minus" because the maximisation choice is coded with 0

        # calculate MSD using observed and predicted transactions
        pmax_predicted1, pmax_predicted2 = model.get_pmax()
        pmax_predicted1 = 1 - pmax_predicted1
        pmax_predicted2 = 1 - pmax_predicted2

        # TODO this method does not provide a consistent final MSD value
        # because it averages many MSD values instead of calculating the MSD on the final pmax.
        # solution adopted: recalculate MSD in MATLAB MSD_analysis
        MSD += mean_squared_deviation([pmax_observed1, pmax_observed2], [pmax_predicted1, pmax_predicted2])

    return MSD/n_iterations, pmax_predicted1, pmax_predicted2


def get_payoff(action):
    return normal(problems[problem_id][action][0], problems[problem_id][action][1])


def mean_squared_deviation(observed_y, predicted_y):
    msd = 0
    for i in xrange(len(observed_y)):
        msd += (predicted_y[i] - observed_y[i]) ** 2
    return msd / len(observed_y)


def get_config_permutations(state_sp, learn_rules, rew_funcs):
    mod_perms = list(itertools.product(state_sp, learn_rules, rew_funcs))
    # make sure qlearning is not combined with stateless
    mod_perms = [perm for perm in mod_perms if constants.STATELESS not in perm or constants.Q_LEARNING not in perm]
    return mod_perms


def get_guesspoints_permutations(a, b, g):
    gp_perms = list(itertools.product(a, b, g))
    return gp_perms


def save_results(file_path, results_filename, results):
    with open(file_path + results_filename, 'w') as results_file:
        for problem_id, problem in results.iteritems():
            print 'problem ', problem_id
            for subj_id, subj in problem.iteritems():
                print 'subject ', subj_id
                for config, resl in subj.iteritems():
                    print 'config ', config
                    print 'params ', resl[0]
                    print 'MSD ', resl[1]
                    print
                    results_file.write(str(problem_id) + ',')  # Problem ID
                    results_file.write(str(subj_id) + ',')     # Subject ID
                    results_file.write(str(resl[1]) + ',')     # MSD
                    results_file.write(str(resl[2]) + ',')     # pmax1
                    results_file.write(str(resl[3]) + ',')     # pmax2
                    results_file.write(str(resl[0][0]) + ',')  # alpha
                    results_file.write(str(resl[0][1]) + ',')  # beta
                    results_file.write(str(resl[0][2]) + ',')  # gamma
                    results_file.write(str(config[0]) + ',')   # state-space
                    results_file.write(str(config[1]) + ',')   # learning rule
                    results_file.write(str(config[2]) + '\n')  # reward function

''' Routine to estimate the mean squared deviation (MSD or mean squared error MSE)
    between the predicted proportion of maximisation choices (Pmax) against the observed Pmax'''
if __name__ == '__main__':

    current_problem = int(sys.argv[1])

    t_total = time.time()
    VERBOSE = 0
    MSD_INIT = 9999
    #TOLERANCE = 1e-4  # 0.0001
    n_iterations = int(sys.argv[2])
    # original data choice code
    # choice_HI = 1;
    # choice_LO = 2;
    # problem condition : payoff distributions (0 high, 1 low)
    problems = {0: {0: (100, 354), 1: (25, 17.7)},
                1: {0: (1300, 354), 1: (1225, 17.7)},
                2: {0: (1300, 17.7), 1: (1225, 17.7)}}

    # path and filename
    file_name = 'BarronErev2003_Thaler_replication.csv'
    # file_name = 'test_greedy_random_generic.csv'
    results_filename = 'results_' + file_name[:-4] + '__' + str(datetime.datetime.now())
    results_filename = results_filename.split()[0]  # split and take first to remove timestamp (after space)
    results_filename += '_MSD_' + str(n_iterations) + 'iterations'
    results_filename += '_prob' + str(current_problem) + '.csv'
    print 'Results file: {}'.format(results_filename)

    # reduce search space based on indications from descriptive MLE based information
    state_spaces = (constants.FULL_HISTORY, constants.LATEST_OUTCOME)
    learning_rules = (constants.Q_LEARNING, constants.AVG_TRACKING)
    reward_functions = (constants.IDENTITY, constants.PT_VALUE_FUNC)
    model_configurations = get_config_permutations(state_spaces, learning_rules, reward_functions)

    #bounds = ((0.00001, 1), (0.00001, 1), (0.00001, 1))

    # # full search
    alphas = [0.0001, 0.0003,  0.001, 0.003,  0.01,  0.03, 0.1, 0.5, 0.7]
    betas =  [0.0001, 0.0003,  0.001, 0.003,  0.01,  0.03, 0.1, 0.5, 0.7]
    gammas = [0.0001, 0.0003,  0.001, 0.003,  0.01,  0.03, 0.1, 0.5, 0.7]

    # simpler
    # alphas = [0.0001,  0.001, 0.1, 0.3]
    # betas  = [0.00001, 0.001, 0.1]
    # gammas = [0.001,    0.01, 0.3]

    guesspoints_permutations = get_guesspoints_permutations(alphas, betas, gammas)

    # load data into dictionary {problem: subjects}
    data_reader = DataReader.DataReader(constants.DATA_FILE_PATH + file_name)
    problem_data = data_reader.read_subject_data()

    # create data structure to hold results
    results = {}

    # save for each player the log_lik of each configuration best param set
    # these will be compared in terms of AIC/BIC to determine if the best config is better than the others
    # for example: (two-states vs stateless)

    # iterate over problems
    for problem_id, subjects in problem_data.iteritems():

        if problem_id == current_problem:
            results[problem_id] = {}

            print 'problem ', problem_id

            # iterate over subjects (fetch subject data)
            for subj_id, subject in subjects.iteritems():

                t_subj = time.time()
                print 'subject ', subj_id

                results[problem_id][subj_id] = {}

                transactions = zip(subject.get_choices(), subject.get_outcomes())

                # iterate over model combinations and guess points
                for configuration in model_configurations:
                    t_config = time.time()

                    # placeholder for first result
                    results[problem_id][subj_id][configuration] = ([0, 0, 0], MSD_INIT)

                    for guesspoints in guesspoints_permutations:

                        msd, pmax1, pmax2 = model_fit(guesspoints, transactions, configuration)

                        # if MSD lower than current estimate,
                        # store MSD, params and MODEL config
                        if msd < results[problem_id][subj_id][configuration][1]:
                            alpha = guesspoints[0]
                            beta = guesspoints[1]
                            gamma = guesspoints[2] if constants.Q_LEARNING in configuration[1] else 0
                            params = [alpha, beta, gamma]
                            results[problem_id][subj_id][configuration] = (params, msd, pmax1, pmax2)

                    print '{5:.2f}s - MSD:{0:.5f} - pmax: {6:.2f} / {7:.2f} - a:{2:.5f} - b:{3:.5f} - g:{4:.5f} - {1!s}'.\
                        format(results[problem_id][subj_id][configuration][1], configuration,
                               results[problem_id][subj_id][configuration][0][0],
                               results[problem_id][subj_id][configuration][0][1],
                               results[problem_id][subj_id][configuration][0][2],
                               time.time() - t_config,
                               results[problem_id][subj_id][configuration][2],
                               results[problem_id][subj_id][configuration][3],)
                    print

                print 'time elapsed for subject {}: {}'.format(subj_id, time.time() - t_subj)

    save_results(constants.RESULTS_FILE_PATH, results_filename, results)

    print 'total time {}'.format(time.time() - t_total)
    print 'completed ' + str(datetime.datetime.now())
