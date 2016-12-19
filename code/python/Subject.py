
class Subject:

    def __init__(self, subj_id):
        self.subject_id = subj_id
        self.problems = [[], [], []]

    def add_trial(self, problem, trial):
        if problem == 1:
            self.problems[0].append(trial)
        if problem == 2:
            self.problems[1].append(trial)
        if problem == 3:
            self.problems[2].append(trial)

    def get_trials(self, problem):
        return self.problems[problem - 1]

class Trial:

    def __init__(self, trial_id, choice, outcome, forgone):
        self.id      = trial_id
        self.choice  = choice
        self.outcome = outcome
        self.forgone = forgone

    def __str__(self):
        return 'trial {}, choice {}, outcome {}, forgone {}'.format(self.id, self.choice, self.outcome, self.forgone)

