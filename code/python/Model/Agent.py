from __future__ import division
import numpy as np
from math import log
import constants


class Agent:

    def __init__(self, theta, state_config, learning_rule, reward_function):
        self.likelihood = 0
        self.params = theta
        self.state_config = state_config
        self.learning_rule = learning_rule
        self.reward_function = reward_function
        self.n_actions = 2
        self.initial_action_value = 0
        self.accumulated_payoffs = 0
        self.current_state = 0

        # initialise structure to store state-action values
        if self.state_config == constants.STATELESS:
            self.action_values = [self.initial_action_value for act_i in xrange(self.n_actions)]
        else:   # two-state case (both latest transaction or full history)
            self.action_values = [[self.initial_action_value for act_i in xrange(self.n_actions)] for state_i in xrange()]

        # unpack parameter array theta (extract gamma only if using qlearning, not if using average-tracking)
        self.alpha = theta[0]
        self.beta = theta[1]
        if self.learning_rule == constants.Q_LEARNING:
            self.gamma = theta[2]

    def update_accumulated_payoffs(self, raw_reward):
        # updates the accumulated payoffs representing the performance of the subject in the task
        self.accumulated_payoffs += raw_reward

    def update_current_state(self, state):
        # updates the current state of the agent
        self.current_state = state

    def update_likelihood(self, log_probability):
        # updates the likelihood of the model with the log_probability of an action
        self.likelihood += log_probability

    def select_action(self, selected_action):
        # implements softmax action selection rule
        # returns log_probability of selecting selected_action

        denominator = 0
        for a in xrange(self.n_actions):
            denominator += np.exp(self.beta * self.action_values[self.current_state][a])
        action_log_probability = self.beta * self.action_values[self.current_state][selected_action] - log(denominator)
        return action_log_probability

    def get_reward(self, raw_reward):
        # translates the raw reward signal (payoff) to the corresponding value of the adopted reward function

        if self.reward_function == constants.IDENTITY:
            return raw_reward

        elif self.reward_function == constants.HTAN:
            return self.htan(raw_reward)

        elif self.reward_function == constants.PT_VALUE_FUNC:
            return self.pt_value_function(raw_reward)

    @staticmethod
    def pt_value_function(raw_reward):

        if raw_reward > 0:
            return raw_reward ** constants.PT_FACTOR
        elif raw_reward < 0:
            return -constants.PT_LOSS_AVERSION * ((-raw_reward) ** constants.PT_FACTOR)
        else:
            return raw_reward

    @staticmethod
    def htan(raw_reward):
        return (1 - np.exp(-raw_reward * constants.HTAN_FACTOR)) / (1 + np.exp(-raw_reward * constants.HTAN_FACTOR))

    def update_action_values(self, reward, action):
        # updates the action values with the processed reward value

        if self.learning_rule == constants.Q_LEARNING:
            next_state = self.get_next_state(reward)

            # update rule
            td_error = reward + self.gamma * max(self.action_values[next_state]) - self.action_values[self.current_state][action]
            self.action_values[self.current_state][action] += self.alpha * td_error

        elif self.learning_rule == constants.AVG_TRACKING:
            pass
            # TODO implement average tracking

    def get_next_state(self, reward):
        # returns the next state depending on the state-space configuration of the model
        # TODO make state values constants, at the moment 0 for profit/gain and 1 for deficit/loss

        if self.state_config == constants.STATELESS:
            return 0

        elif self.state_config == constants.FULL_HISTORY:
            # in the full history configuration return state 0 when in profit, 1 in loss
            return 0 if self.accumulated_payoffs >= 0 else 1

        elif self.state_config == constants.LATEST_OUTCOME:
            # in the latest outcome configuration return state 0 when last payoff was profit, 1 otherwise
            return 0 if reward >= 0 else 1
