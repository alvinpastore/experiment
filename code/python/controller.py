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


def model_fit(model, transactions):
    t1 = time.time()
    for trial_i in xrange(len(transactions)):
        action = transactions[trial_i][0]
        outcome = transactions[trial_i][1]

        if VERBOSE:
            print 'act ' + str(action) + ' - outcome ' + str(outcome)

        act_log_prob = model.select_action(action)

        if VERBOSE:
            print 'act log prob ' + str(act_log_prob)
            print 'model action values' + str(model.action_values)

        model.update_action_values(outcome, action)

        if VERBOSE:
            print 'model action values' + str(model.action_values)
            print
    if VERBOSE:
        print 'model params {}, {}'.format(model.alpha, model.beta)
        print 'log likelihood ' + str(model.log_likelihood)
        print 'model fit in ' + str(time.time() - t1) + 'sec' + '\n'
    return model.log_likelihood


def get_modules_permutations(state_sp, learn_rules, rew_funcs):
    mod_perms = list(itertools.product(state_sp, learn_rules, rew_funcs))
    # make sure qlearning is not combined with stateless
    mod_perms = [perm for perm in mod_perms if constants.STATELESS not in perm or constants.Q_LEARNING not in perm]
    return mod_perms


def get_guesspoints_permutations(a, b, g):
    gp_perms = list(itertools.product(a, b, g))
    return gp_perms


if __name__ == '__main__':
    VERBOSE = 0

    state_spaces = (constants.STATELESS, constants.FULL_HISTORY, constants.LATEST_OUTCOME)
    learning_rules = (constants.Q_LEARNING, constants.AVG_TRACKING)
    reward_functions = (constants.IDENTITY, constants.HTAN, constants.PT_VALUE_FUNC)
    model_configurations = get_modules_permutations(state_spaces, learning_rules, reward_functions)

    alphas = (0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 0.5, 0.7)
    betas =  ( 0.01,  0.03,  0.1,  0.3,   1,   3,  10, 30)
    gammas = (0.001, 0.003, 0.01, 0.03, 0.1, 0.3, 0.5, 0.7)

    alphas = (0.1, 0.3, 0.5, 0.7)
    betas = (0.0001, 0.0003, 0.001, 0.1, 1)
    gammas = (0.01, 0.2)
    guesspoints_permutations = get_guesspoints_permutations(alphas, betas, gammas)

    # path and filename
    file_path = '../../data/BarronErev2003_Thaler_replication.txt'
    print os.listdir('../../data/')
    data_reader = DataReader(file_path)
    # load data into dictionary {problem: subjects}
    problem_data = data_reader.read_subject_data()

    # TODO create data structure to hold results

    # iterate over problems
    for problem_id, subjects in problem_data.iteritems():
        print 'problem ', problem_id

        # iterate over subjects (fetch subject data)
        for subj_id, subject in subjects.iteritems():
            print 'subject ', subj_id
            transactions = zip(subject.get_choices(), subject.get_outcomes())
            MLES = []

            # iterate over model combinations
            # iterate over guess points
            for configuration in model_configurations:
                for guesspoints in guesspoints_permutations:
                    model = Model.Model(guesspoints, *configuration)
                    MLE = model_fit(model, transactions)
                    if MLE > len(transactions) * log(0.5):
                        MLES.append(MLE)
                        MODEL = (guesspoints, configuration)
                        # print str(configuration) + ' ' + str(guesspoints) + ' ' + str(MLE)
            if len(MLES) > 0:
                print 'best MLE = ', max(MLES)
                print 'model = ', MODEL
                print

            #TODO implement the fmin
            # call minimisation routine on data and model
            # minimise model_fit(model, transaction)
