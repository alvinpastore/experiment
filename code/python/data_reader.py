from Subject import Subject
from Subject import Trial
from model_fit import fit

# id of the problem from thaler_et_al_1997 and barron_erev_2003
Thaler_problem_ID1 = 34
Thaler_problem_ID2 = 35
Thaler_problem_ID3 = 36


# probclr feed va1     pa1     va2     sa      vb1    pb1     vb2      sb       id       t        d       v       f
# probid  ? , val1A.  prob1A, val2A, stddevA, val1B, prob1B, val2B, stddevB,  subjID,  trial,  choice, observed, forgone
# ['34', '1', '100',  '1.0',   '.',   '354',   '25', '1.00',  '.',    '17',    '12',   '200',    '2',    '2',    '501']

with open('../../data/BarronErev2003.txt','r') as data_file:
    # skip headers and white line
    data_file.readline()
    data_file.readline()
    # get all following lines
    lines = [l.strip().split() for l in data_file.readlines()]


# list of lists structure to store the lines for the three problems
prob_lines = [[],[],[]]

for line in lines:
    problem_id = line[0]

    if int(problem_id) == Thaler_problem_ID1:
        prob_lines[0].append(line)

    if int(problem_id) == Thaler_problem_ID2:
        prob_lines[1].append(line)

    if int(problem_id) == Thaler_problem_ID3:
        prob_lines[2].append(line)

print "thaler problem 1 " +str(prob_lines[0].__len__()) + "lines"
print "thaler problem 2 " +str(prob_lines[0].__len__()) + "lines"
print "thaler problem 3 " +str(prob_lines[0].__len__()) + "lines"

subjects = {}

# rearranging prob1 lines into subjects
prob_id = 1
for line in prob_lines[0]:
    # val1_A = line[2]
    # prob_A = line[3]
    # val2_A = line[4]
    # stdd_A = line[5]
    # val1_B = line[6]
    # prob_B = line[7]
    # val2_B = line[8]
    # stdd_B = line[9]
    subj_id = line[10]
    trial_id  = line[11]
    choice = line[12]
    outcome = line[13]
    forgone = line[14]

    trial = Trial(trial_id, choice, outcome, forgone)

    if subj_id not in subjects.keys():
        subjects[subj_id] = Subject(subj_id)

    subjects[subj_id].add_trial(prob_id, trial)

for subject in subjects.values():
    fit(subject,prob_id)

    raw_input()
# print "prob {0}, subj {1}, trial {2}, choice {3}, outcome {4}".format(1, subj_id, trial, choice, outcome)



