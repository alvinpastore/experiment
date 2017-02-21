from __future__ import division
from Model import Model
from Model import constants
from DataReader import DataReader
import itertools
import os
from scipy.optimize import minimize
import numpy as np
from math import log
import time


def model_fit(*args):

    params, transactions, configuration = args

    # generate a model with theta and configuration
    model = Model.Model(params, *configuration)

    t_initial = time.time()
    for trial_i in xrange(len(transactions)):
        action = transactions[trial_i][0]
        outcome = transactions[trial_i][1]

        model.select_action(action)

        model.update_action_values(outcome, action)

    if VERBOSE:
        print 'log likelihood ' + str(model.log_likelihood)
        print 'model params {}, {}'.format(model.alpha, model.beta)
        print 'model fit in ' + str(time.time() - t_initial) + 'sec' + '\n'
    return -model.log_likelihood


def get_modules_permutations(state_sp, learn_rules, rew_funcs):
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
            results_file.write('problem ' + str(problem_id) + '\n')
            for subj_id, subj in problem.iteritems():
                print 'subject ', subj_id
                results_file.write('subject ' + str(subj_id) + '\n')
                for config, resl in subj.iteritems():
                    print 'config ', config
                    print 'params ', resl[0]
                    print 'MLE ', resl[1]
                    print
                    results_file.write(str(config[0]) + ',')   # state-space
                    results_file.write(str(config[1]) + ',')   # learning rule
                    results_file.write(str(config[2]) + ',')   # reward function
                    results_file.write(str(resl[0][0]) + ',')  # alpha
                    results_file.write(str(resl[0][1]) + ',')  # beta
                    results_file.write(str(resl[0][2]) + ',')  # gamma
                    results_file.write(str(resl[1]) + '\n')    # MLE


if __name__ == '__main__':
    t_total = time.time()
    VERBOSE = 0
    MLE_INIT = 9999

    # path and filename
    data_file_path = '../../data/'
    file_name = 'BarronErev2003_Thaler_replication.txt'
    results_file_path = '../../results/'
    results_filename = 'test_results.txt'

    state_spaces = (constants.STATELESS, constants.FULL_HISTORY, constants.LATEST_OUTCOME)
    learning_rules = (constants.Q_LEARNING, constants.AVG_TRACKING)
    reward_functions = (constants.IDENTITY, constants.TANH, constants.PT_VALUE_FUNC)
    model_configurations = get_modules_permutations(state_spaces, learning_rules, reward_functions)

    bounds = ((0.0001, 1), (0.00001, 1), (0.001, 1))
    # alphas = (0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 0.5, 0.7)
    # betas =  ( 0.01,  0.03,  0.1,  0.3,   1,   3,  10, 30)
    # gammas = (0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 0.5, 0.7)

    alphas = (0.0001,  0.001, 0.1, 0.3)
    betas  = (0.00001, 0.001, 0.1)
    gammas = (0.001,    0.01, 0.3)

    guesspoints_permutations = get_guesspoints_permutations(alphas, betas, gammas)

    # load data into dictionary {problem: subjects}
    data_reader = DataReader(data_file_path + file_name)
    problem_data = data_reader.read_subject_data()

    # create data structure to hold results
    results = {}

    # save for each player the log_lik of each configuration best param set
    # these will be compared in terms of AIC/BIC to determine if the best config is better than the others
    # for example: (two-states vs stateless)

    # iterate over problems
    for problem_id, subjects in problem_data.iteritems():

        results[problem_id] = {}

        print 'problem ', problem_id

        # iterate over subjects (fetch subject data)
        for subj_id, subject in subjects.iteritems():
            t_subj = time.time()
            print 'subject ', subj_id

            results[problem_id][subj_id] = {}

            transactions = zip(subject.get_choices(), subject.get_outcomes())

            MLE = MLE_INIT
            params = []

            # iterate over model combinations and guess points
            for configuration in model_configurations:
                t_config = time.time()

                # placeholder for first result
                results[problem_id][subj_id][configuration] = ([0, 0, 0], MLE_INIT)

                for guesspoints in guesspoints_permutations:

                    # minimise the fitting function
                    minimisation_results = minimize(model_fit, guesspoints,
                                                    args=(transactions, configuration), bounds=bounds,
                                                    method='TNC', tol=1e-06)

                    # if successful and MLE lower than current estimate,
                    # store log_lik (MLE), params and MODEL config
                    if minimisation_results['success'] and minimisation_results['fun'] < MLE:
                        MLE = minimisation_results['fun']
                        params = list(minimisation_results['x'])
                        config = configuration

                    # store the results of the configuration if the LL is better than the previous one
                    if minimisation_results['fun'] < results[problem_id][subj_id][configuration][1]:
                        results[problem_id][subj_id][configuration] = (minimisation_results['x'], minimisation_results['fun'])

                print '{5:.2f} s -> MLE:{0:.2f} - a:{2:.5f} - b:{3:.5f} - g:{4:.5f} - {1!s}'.format(MLE, configuration, params[0], params[1], params[2], time.time()-t_config)

            if MLE >= MLE_INIT:
                print 'no solution for subject'
            print 'time elapsed for subject {}: {}'.format(subj_id, time.time() - t_subj)

    save_results(results_file_path, results_filename, results)

    print 'total time {}'.format(time.time() - t_total)
