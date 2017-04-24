from __future__ import division

import itertools
import time
import datetime

from numpy.random import normal
from operator import add

from Model import Model
from Model import constants


# reads the parameters estimated with MLE and AIC_weights and
# stores them into a dictionary (subj: params)for each condition
def read_subj_parameters(weighted_average_models_file_name):

    parameters = {0: {}, 1: {}, 2: {}}

    with open(weighted_average_models_file_name, 'r') as weighted_average_models:
        lines = [l.strip().split(',') for l in weighted_average_models.readlines()]

    for l in lines:
        pr_id = int(float(l[0]))
        su_id = int(float(l[1]))
        parameters[pr_id][su_id] = (float(l[2]), float(l[3]), float(l[4]))

    return parameters


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

    parameters, config = args

    # generate a model with theta and configuration
    model = Model.Model(parameters, *config)

    simulated_values = {'choices': [], 'payoffs': []}

    for trial_i in xrange(n_trials):

        # pick action softmax
        action = model.pick_action()

        # receive reward from problem for action picked
        reward = get_payoff(action)

        # store choice and payoff
        simulated_values['choices'].append(action)
        simulated_values['payoffs'].append(reward)

        # update action values
        model.update_action_values(reward, action)

    return simulated_values


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
    n_iterations = 10  # number of iterations for smoothing the simulated choices
    n_trials = 200      # number of choice interactions
    n_models = 15       # number of model configurations

    # original data choice code
    # choice_HI = 1;
    # choice_LO = 2;
    # problem condition : payoff distributions (0 high, 1 low)
    problems = {0: {0: ( 100, 354),  1: (  25, 17.7)},
                1: {0: (1300, 354),  1: (1225, 17.7)},
                2: {0: (1300, 17.7), 1: (1225, 17.7)}}

    avg_params = read_avg_parameters(constants.RESULTS_FILE_PATH + file_name_csv)
    subj_params = read_subj_parameters(constants.RESULTS_FILE_PATH + file_name_csv)

    state_spaces = (constants.STATELESS, constants.FULL_HISTORY, constants.LATEST_OUTCOME)
    learning_rules = (constants.Q_LEARNING, constants.AVG_TRACKING)
    reward_functions = (constants.IDENTITY, constants.TANH, constants.PT_VALUE_FUNC)
    model_configurations = get_config_permutations(state_spaces, learning_rules, reward_functions)

    choices = {0: [], 1: [], 2: []}
    payoffs = {0: [], 1: [], 2: []}
    smoothing_denominator = n_models * n_iterations * n_subj

    for prob_id in xrange(n_probs):
        prob_time = time.time()

        simulated_choices = [0] * n_trials
        simulated_payoffs = [0] * n_trials

        # iterate over subjects, model configurations and smoothing iterations
        for subj_id in xrange(1, n_subj+1):
            subj_time = time.time()

            params = subj_params[prob_id][subj_id]

            for configuration in model_configurations:

                for iteration in xrange(n_iterations):

                    # run simulation
                    temp_values = model_simulate(params, configuration)
                    temp_choices = temp_values['choices']
                    temp_payoffs = temp_values['payoffs']

                    simulated_choices = map(add, simulated_choices, temp_choices)
                    simulated_payoffs = map(add, simulated_payoffs, temp_payoffs)

            print '{} - {} : {} secs'.format(prob_id, subj_id, time.time() - subj_time)

        choices[prob_id] = [float(x)/smoothing_denominator for x in simulated_choices]
        payoffs[prob_id] = [float(x)/smoothing_denominator for x in simulated_payoffs]

        print 'prob {} sec'.format(time.time() - prob_time)

    for prob_id, smoothed_choice_set in choices.iteritems():
        print 'choices problem ', prob_id
        print smoothed_choice_set
        print

    for prob_id, smoothed_payoff_set in payoffs.iteritems():
        print 'payoffs problem ', prob_id
        print smoothed_payoff_set
        print

    print 'total {} sec'.format(time.time() - t_total)
    print 'completed ' + str(datetime.datetime.now())
