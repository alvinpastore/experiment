from __future__ import division

import itertools
import time
import datetime

from numpy.random import normal
from operator import add, div

from Model import Model
from Model import constants

# reads the parameters estimated with MLE and AIC_weights and
# stores them into a dictionary (subj: params)for each condition
def read_subj_parameters(weighted_average_models_file_name):

    params = {0: {}, 1: {}, 2: {}}

    with open(weighted_average_models_file_name, 'r') as weighted_average_models:
        lines = [l.strip().split(',') for l in weighted_average_models.readlines()]

    for l in lines:
        pr_id = int(float(l[0]))
        su_id = int(float(l[1]))
        params[pr_id][su_id] = (float(l[2]), float(l[3]), float(l[4]))

    return params

# reads the parameters estimated with MLE and AIC_weights and
# averages them into a single set of params for each condition
def read_avg_parameters(weighted_average_models_file_name):

    alpha = [0, 0, 0]
    beta =  [0, 0, 0]
    gamma = [0, 0, 0]

    with open(weighted_average_models_file_name, 'r') as weighted_average_models:
        lines = [l.strip().split(',') for l in weighted_average_models.readlines()]

        for l in lines:
            pr_id = int(float(l[0]))

            alpha[pr_id] += float(l[2])
            beta[pr_id] += float(l[3])
            gamma[pr_id] += float(l[4])

    avg_alpha = [a / n_subj for a in alpha]
    avg_beta =  [b / n_subj for b in beta]
    avg_gamma = [g / n_subj for g in gamma]

    return {'alpha': avg_alpha, 'beta': avg_beta, 'gamma': avg_gamma}


def model_simulate(*args):

    params, configuration = args

    # generate a model with theta and configuration
    model = Model.Model(params, *configuration)

    sim_choices = []

    for trial_i in xrange(n_trials):

        # pick action softmax
        action = model.pick_action()

        # store choice
        sim_choices.append(action)

        # receive reward from problem for action picked
        reward = get_payoff(action)

        # update action values
        model.update_action_values(reward, action)

    return sim_choices


def get_payoff(action):
    return normal(problems[prob_id][action][0], problems[prob_id][action][1])


def get_config_permutations(state_sp, learn_rules, rew_funcs):
    mod_perms = list(itertools.product(state_sp, learn_rules, rew_funcs))
    # make sure qlearning is not combined with stateless
    mod_perms = [perm for perm in mod_perms if constants.STATELESS not in perm or constants.Q_LEARNING not in perm]
    return mod_perms


''' Routine to estimate the mean squared deviation (MSD or mean squared error MSE)
    between the predicted proportion of maximisation choices (Pmax) against the observed Pmax'''
if __name__ == '__main__':
    t_total = time.time()

    # path and filename
    file_name_csv = 'best_weighted_avg_models_results_BarronErev2003_Thaler_replication__2017-03-20.csv'

    n_probs = 3         # number of problems
    n_subj = 12         # number of subjects
    n_iterations = 1000  # number of iterations for smoothing the simulated choices
    n_trials = 200      # number of choice interactions
    n_models = 15       # number of model configurations

    # problem condition : payoff distributions (1 low, 0 high)
    #TODO invert 0 and 1 and make sure is in line with the other codes
    problems = {0: {1: (25, 17.7),   0: (100, 354)},
                1: {1: (1225, 17.7), 0: (1300, 354)},
                2: {1: (1225, 17.7), 0: (1300, 17.7)}}

    avg_params = read_avg_parameters(constants.RESULTS_FILE_PATH + file_name_csv)
    subj_params = read_subj_parameters(constants.RESULTS_FILE_PATH + file_name_csv)

    state_spaces = (constants.STATELESS, constants.FULL_HISTORY, constants.LATEST_OUTCOME)
    learning_rules = (constants.Q_LEARNING, constants.AVG_TRACKING)
    reward_functions = (constants.IDENTITY, constants.TANH, constants.PT_VALUE_FUNC)
    model_configurations = get_config_permutations(state_spaces, learning_rules, reward_functions)

    choices = {0: [], 1: [], 2: []}
    smoothing_denominator = n_models * n_iterations * n_subj

    for prob_id in xrange(n_probs):
        prob_time = time.time()

        simulated_choices = [0] * n_trials

        for subj_id in xrange(1, n_subj+1):
            subj_time = time.time()
            print '{} - {} '.format(prob_id, subj_id)

            params = subj_params[prob_id][subj_id]

            # iterate over model configurations and the number of iterations (for smoothing)
            for configuration in model_configurations:
                #print 'config ', configuration

                for iteration in xrange(n_iterations):

                    # run simulation
                    simulated_choices = map(add, simulated_choices, model_simulate(params, configuration))
            print 'subj {} sec'.format(time.time()-subj_time)
        choices[prob_id] = [float(x)/smoothing_denominator for x in simulated_choices]

        for choice in choices[prob_id]:
            print choice

        print 'prob {} sec'.format(time.time()-prob_time)
    for prob_id, results in choices.iteritems():
        print 'problem ', prob_id
        print results
        print
    print 'total time {}'.format(time.time() - t_total)
    print 'completed ' + str(datetime.datetime.now())