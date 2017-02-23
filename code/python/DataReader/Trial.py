class Trial:

    def __init__(self, trial_id, choice, outcome, forgone):
        self.id      = trial_id
        self.choice  = choice
        self.outcome = outcome
        self.forgone = forgone

    def __str__(self):
        return 'trial {}, choice {}, outcome {}, forgone {}'.format(self.id, self.choice, self.outcome, self.forgone)

    def get_id(self):
        return self.id

    def get_choice(self):
        return self.choice

    def get_outcome(self):
        return self.outcome

    def get_forgone(self):
        return self.forgone
