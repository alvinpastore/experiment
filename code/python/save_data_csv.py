from DataReader import DataReader

# load data into subjects objects
path = '../../data/'
file_name = 'BarronErev2003_Thaler_replication.txt'

dr = DataReader(path + file_name)

problem_data = dr.read_subject_data()


out_file_name = 'BarronErev2003_Thaler_replication.csv'

with open(path + out_file_name, 'w') as out_file:

    for problem_id, subjs in problem_data.iteritems():

        for subj_id, subj in subjs.iteritems():
            trials = subj.get_trials()

            for t in trials:

                print str(problem_id + 1) + ',' + str(subj_id) + ',' + str(t.get_id()) +\
                      ',' + str(t.get_choice()) + ',' + str(t.get_outcome())

                out_file.write(str(problem_id + 1) + ',' + str(subj_id) + ',' + str(t.get_id()) +
                               ',' + str(t.get_choice()) + ',' + str(t.get_outcome()) + '\n')
