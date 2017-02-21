from Subject import Subject
from Trial import Trial


class DataReader:

    def __init__(self, data_file_name):
        self.problems = {}
        self.data_file_name = data_file_name

        # id of the problem from thaler_et_al_1997 and barron_erev_2003
        if 'txt' in self.data_file_name:
            self.thaler_problem_id1 = 34
            self.thaler_problem_id2 = 35
            self.thaler_problem_id3 = 36

        # adjusted id in csv file
        elif 'csv' in self.data_file_name:
            self.thaler_problem_id1 = 1
            self.thaler_problem_id2 = 2
            self.thaler_problem_id3 = 3

    def read_subject_data(self):

        if 'txt' in self.data_file_name and 'csv' not in self.data_file_name:

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

                # populating subjects with trials
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

                    # trial values from prob_lines
                    trial = Trial(trial_id, choice, outcome, forgone)

                    if subj_id not in subjects.keys():
                        subjects[subj_id] = Subject(subj_id)

                    subjects[subj_id].add_trial(trial)

                # adding the subjects to the problem
                self.problems[prob_id - 1] = subjects

            return self.problems
        elif 'txt' not in self.data_file_name and 'csv' in self.data_file_name:
            with open(self.data_file_name, 'r') as data_file:
                # get all following lines
                lines = [l.strip().split(',') for l in data_file.readlines()]

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

                # populating subjects with trials
                for line in prob_lines[prob_id - 1]:
                    # val1_A = line[2]
                    # prob_A = line[3]
                    # val2_A = line[4]
                    # stdd_A = line[5]
                    # val1_B = line[6]
                    # prob_B = line[7]
                    # val2_B = line[8]
                    # stdd_B = line[9]
                    subj_id = int(line[1])
                    trial_id = int(line[2])
                    choice = int(line[3])
                    outcome = float(line[4])
                    forgone = None

                    # trial values from prob_lines
                    trial = Trial(trial_id, choice, outcome, forgone)

                    if subj_id not in subjects.keys():
                        subjects[subj_id] = Subject(subj_id)

                    subjects[subj_id].add_trial(trial)

                # adding the subjects to the problem
                self.problems[prob_id - 1] = subjects

            return self.problems

        else:
            'File format not valid'
            return -1


# example of usage
if __name__ == "__main__":

    # path and filename
    path = '../../../data/'
    file_name = 'BarronErev2003_Thaler_replication.txt'
    file_name_csv = 'BarronErev2003_Thaler_replication.csv'

    dr = DataReader(path + file_name_csv)

    # load data into dictionary {problem: subjects}
    problem_data = dr.read_subject_data()

    for problem_id, subjs in problem_data.iteritems():
        print 'problem: ', problem_id

        # for each subject
        for subj_id, subj in subjs.iteritems():
            print 'subject: ', subj_id

            transactions = zip(subj.get_choices(), subj.get_outcomes())
            for trans_idx in xrange(len(transactions)):
                print transactions[trans_idx][0]
                print transactions[trans_idx][1]
                print

                raw_input()

            # get trials and print them
            trials = subj.get_trials()
            for trial in trials:
                print trial
        raw_input()

