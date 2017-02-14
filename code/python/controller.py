from __future__ import division
from Model import Model
from DataReader import DataReader
from scipy.optimize import minimize
import numpy as np
from math import log
import time


def mode_fit(model, transactions):
    for trial_i in xrange(len(transactions)):
        action = transactions[trial_i][0]
        outcome = transactions[trial_i][1]

        model.select_action(action)
        model.update_action_values(outcome, action)

    return model.log_likelihood

if __name__ == '__main__':

    # path and filename
    file_path = '../../data/BarronErev2003_Thaler_replication.txt'
    data_reader = DataReader(file_path)
    # load data into dictionary {problem: subjects}
    problem_data = data_reader.read_subject_data()

    # TODO create data structure to hold results

    # iterate over problems
    for problem_id, subjects in problem_data.iteritems():
        print problem_id

        # iterate over subjects (fetch subject data)
        for subject in subjects:

            transactions = zip(subject.get_choices(), subject.get_outcomes())

            # iterate over model combinations (make sure qlearning is not combined with stateless)

            model = Model()

            # iterate over guess points

            # call minimisation routine on data and model

