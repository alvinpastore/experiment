
class Subject:

    def __init__(self, subj_id):
        self.id = subj_id
        self.trials = []

    def add_trial(self, trial):
        self.trials.append(trial)

    def get_id(self):
        return self.id

    def get_trials(self):
        return self.trials
