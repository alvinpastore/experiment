from DataReader import DataReader

# load data into subjects objects
path = '../../data/'
file_name = 'BarronErev2003_Thaler_replication.txt'


dr = DataReader(path + file_name)

problem_data = dr.read_subject_data()

for problem_id, subjs in problem_data.iteritems():
    print problem_id
    for subj_id, subj in subjs.iteritems():
        print subj_id
        trials = subj.get_trials()
        for t in trials:
            print t
    raw_input()
