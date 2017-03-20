from __future__ import division

import numpy as np

from Model import constants
from DataReader import DataReader


'''
Calculates and stores in a csv file two measures on the subjects interactions:
- performance: sum of the outcomes
- payoff_variability: standard deviation of the outcomes
'''

if __name__ == '__main__':

    file_name = 'BarronErev2003_Thaler_replication.csv'

    # load data into dictionary {problem: subjects}
    data_reader = DataReader.DataReader(constants.DATA_FILE_PATH + file_name)
    problem_data = data_reader.read_subject_data()

    with open(constants.RESULTS_FILE_PATH + 'measures_' + file_name, 'w') as measures_file:

        # iterate over problems
        for problem_id, subjects in problem_data.iteritems():

            print 'problem ', problem_id

            # iterate over subjects (fetch subject data)
            for subj_id, subject in subjects.iteritems():

                print 'sub {} - performance {} -  pv {} '.\
                    format(subj_id, sum(subject.get_outcomes()), np.std(subject.get_outcomes()))
                measures_file.write(str(problem_id) + ',')                       # Problem ID
                measures_file.write(str(subj_id) + ',')                          # Subject ID
                measures_file.write(str(sum(subject.get_outcomes())) + ',')      # Performance
                measures_file.write(str(np.std(subject.get_outcomes())) + '\n')  # PV

            print
