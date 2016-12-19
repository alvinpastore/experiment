from DataReader import DataReader

# load data into subjects objects
path = '../../data/'
file_name = 'BarronErev2003.txt'


dr = DataReader(path + file_name)

data = dr.read_subject_data()

for problem_id, subjects in data.items():
    print problem_id
    print subjects
    print subjects[1].get_trials(1)
    print subjects[1].get_trials(2)
    print subjects[1].get_trials(3)
    raw_input()
