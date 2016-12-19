from Subject import Subject
from Trial import Trial


class DataReader:

    def __init__(self, data_file_name):
        self.problems = {}
        # id of the problem from thaler_et_al_1997 and barron_erev_2003
        self.thaler_problem_id1 = 34
        self.thaler_problem_id2 = 35
        self.thaler_problem_id3 = 36
        self.data_file_name = data_file_name

    def read_subject_data(self, prob_id):

        # probclr feed va1     pa1     va2     sa      vb1    pb1     vb2      sb       id       t        d       v       f
        # probid  ? , val1A.  prob1A, val2A, stddevA, val1B, prob1B, val2B, stddevB,  subjID,  trial,  choice, observed, forgone
        # ['34', '1', '100',  '1.0',   '.',   '354',   '25', '1.00',  '.',    '17',    '12',   '200',    '2',    '2',    '501']

        with open(self.data_file_name, 'r') as data_file:
            # skip headers and white line
            data_file.readline()
            data_file.readline()
            # get all following lines
            lines = [l.strip().split() for l in data_file.readlines()]

        # list of lists structure to store the lines for the three problems
        prob_lines = [[], [], []]

        for line in lines:
            problem_id = line[0]

            if int(problem_id) == self.thaler_problem_id1:
                prob_lines[0].append(line)

            if int(problem_id) == self.thaler_problem_id2:
                prob_lines[1].append(line)

            if int(problem_id) == self.thaler_problem_id3:
                prob_lines[2].append(line)

        print "thaler problem 1 " + str(prob_lines[0].__len__()) + "lines"
        print "thaler problem 2 " + str(prob_lines[0].__len__()) + "lines"
        print "thaler problem 3 " + str(prob_lines[0].__len__()) + "lines"

        # rearranging prob_id lines into subjects
        for line in prob_lines[prob_id - 1]:
            # val1_A = line[2]
            # prob_A = line[3]
            # val2_A = line[4]
            # stdd_A = line[5]
            # val1_B = line[6]
            # prob_B = line[7]
            # val2_B = line[8]
            # stdd_B = line[9]
            subj_id = int(line[10])
            trial_id = int(line[11])
            choice = int(line[12])
            outcome = float(line[13])
            forgone = float(line[14])

            trial = Trial(trial_id, choice, outcome, forgone)

            if subj_id not in self.subjects.keys():
                self.subjects[subj_id] = Subject(subj_id)

            self.subjects[subj_id].add_trial(prob_id, trial)

        return self.subjects

    def read_subject_data(self):

        with open(self.data_file_name, 'r') as data_file:
            # skip headers and white line
            data_file.readline()
            data_file.readline()
            # get all following lines
            lines = [l.strip().split() for l in data_file.readlines()]

        # list of lists structure to store the lines for the three problems
        prob_lines = [[], [], []]

        for line in lines:
            problem_id = line[0]

            if int(problem_id) == self.thaler_problem_id1:
                prob_lines[0].append(line)

            if int(problem_id) == self.thaler_problem_id2:
                prob_lines[1].append(line)

            if int(problem_id) == self.thaler_problem_id3:
                prob_lines[2].append(line)

        print "thaler problem 1 " + str(prob_lines[0].__len__()) + "lines"
        print "thaler problem 2 " + str(prob_lines[1].__len__()) + "lines"
        print "thaler problem 3 " + str(prob_lines[2].__len__()) + "lines"

        for prob_id in [1, 2, 3]:

            subjects = {}

            # rearranging prob_id lines into subjects
            for line in prob_lines[prob_id - 1]:
                # val1_A = line[2]
                # prob_A = line[3]
                # val2_A = line[4]
                # stdd_A = line[5]
                # val1_B = line[6]
                # prob_B = line[7]
                # val2_B = line[8]
                # stdd_B = line[9]
                subj_id = int(line[10])
                trial_id = int(line[11])
                choice = int(line[12])
                outcome = float(line[13])
                forgone = float(line[14])

                trial = Trial(trial_id, choice, outcome, forgone)

                if subj_id not in subjects.keys():
                    subjects[subj_id] = Subject(subj_id)

                subjects[subj_id].add_trial(trial)

            self.problems[prob_id - 1] = subjects

        return self.problems


