from model_fit import fit
from DataReader import DataReader

# load data into subjects objects
path = '../../data/'
file_name = 'BarronErev2003.txt'
prob_id = 1

dr = DataReader(path + file_name)
subjects = dr.read_subject_data(prob_id)

# fitting routine on subjects for problem prob_id
nActions = 2
nStates = 2

for subject in subjects.values():
    NLL, params = fit(subject, prob_id, nActions, nStates)
    print 'subj {}, NLL {} with params {}'.format(subject.subject_id, NLL, params)
    # raw_input()
# print "prob {0}, subj {1}, trial {2}, choice {3}, outcome {4}".format(1, subj_id, trial, choice, outcome)
