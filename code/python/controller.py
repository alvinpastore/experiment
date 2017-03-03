from __future__ import division

import itertools
import time
import datetime

from scipy.optimize import minimize

from Model import Model
from Model import constants
from DataReader import DataReader


def model_fit(*args):

    params, transactions, configuration = args

    # generate a model with theta and configuration
    model = Model.Model(params, *configuration)

    t_initial = time.time()
    for trial_i in xrange(len(transactions)):
        action = transactions[trial_i][0]
        outcome = transactions[trial_i][1]

        model.select_action(action)
        reward = model.get_reward(outcome)
        model.update_action_values(reward, action)

    if VERBOSE:
        print 'log likelihood ' + str(model.log_likelihood)
        print 'model params {}, {}'.format(model.alpha, model.beta)
        print 'model fit in ' + str(time.time() - t_initial) + 'sec' + '\n'
    return -model.log_likelihood


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
                    print 'MLE ', resl[1]
                    print
                    results_file.write(str(problem_id) + ',') # Problem ID
                    results_file.write(str(subj_id) + ',')    # Subject ID
                    results_file.write(str(resl[1]) + ',')     # MLE
                    results_file.write(str(resl[0][0]) + ',')  # alpha
                    results_file.write(str(resl[0][1]) + ',')  # beta
                    results_file.write(str(resl[0][2]) + ',')  # gamma
                    results_file.write(str(config[0]) + ',')   # state-space
                    results_file.write(str(config[1]) + ',')   # learning rule
                    results_file.write(str(config[2]) + '\n')  # reward function


if __name__ == '__main__':
    t_total = time.time()
    VERBOSE = 0
    MLE_INIT = 9999
    TOLERANCE = 1e-4  # 0.0001
    # path and filename

    file_name = 'BarronErev2003_Thaler_replication.csv'
    file_name = 'test_greedy_random_generic.csv'
    results_filename = 'results_' + file_name[:-4] + '__' + str(datetime.datetime.now()) + '.csv'
    results_filename = results_filename.split()[0]  # split and take first to remove timestamp (after space)
    print 'Results file: {}'.format(results_filename)

    state_spaces = (constants.STATELESS, constants.FULL_HISTORY, constants.LATEST_OUTCOME)
    learning_rules = (constants.Q_LEARNING, constants.AVG_TRACKING)
    reward_functions = (constants.IDENTITY, constants.TANH, constants.PT_VALUE_FUNC)
    model_configurations = get_config_permutations(state_spaces, learning_rules, reward_functions)

    bounds = ((0.0001, 1), (0.00001, 1), (0.001, 1))
    # alphas = (0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 0.5, 0.7)
    # betas =  ( 0.01,  0.03,  0.1,  0.3,   1,   3,  10, 30)
    # gammas = (0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 0.5, 0.7)

    alphas = [0.0001,  0.001, 0.1, 0.3]
    betas  = [0.00001, 0.001, 0.1]
    gammas = [0.001,    0.01, 0.3]

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
                                                    method='TNC', options={'ftol': TOLERANCE, 'xtol': TOLERANCE})

                    # TODO if MLE < prev_MLE store in results_dict (overwrite)
                    # TODO bug is that after finding the best, the following are not MLEs of the config/theta
                    # but still the best replicated many times

                    # if successful and MLE lower than current estimate,
                    # store log_lik (MLE), params and MODEL config
                    # store the results of the configuration if the LL is better than the previous one
                    if minimisation_results['success'] \
                            and minimisation_results['fun'] < results[problem_id][subj_id][configuration][1]:

                        results[problem_id][subj_id][configuration] = (minimisation_results['x'], minimisation_results['fun'])

                print '{5:.2f} s -> MLE:{0:.2f} - a:{2:.5f} - b:{3:.5f} - g:{4:.5f} - {1!s}'.\
                    format(results[problem_id][subj_id][configuration][1], configuration,
                           results[problem_id][subj_id][configuration][0][0],
                           results[problem_id][subj_id][configuration][0][1],
                           results[problem_id][subj_id][configuration][0][2],
                           time.time()-t_config)
                print

            print 'time elapsed for subject {}: {}'.format(subj_id, time.time() - t_subj)

    save_results(constants.RESULTS_FILE_PATH, results_filename, results)

    print 'total time {}'.format(time.time() - t_total)
    print 'completed ' + str(datetime.datetime.now())
