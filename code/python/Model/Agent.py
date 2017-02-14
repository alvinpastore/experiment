from __future__ import division
import numpy as np
from math import log
import constants


class Agent:

    def __init__(self, theta, state_config, learning_rule, reward_function):

        if state_config == constants.STATELESS and learning_rule == constants.Q_LEARNING:
            print 'Cannot combine Q-Learning with stateless configuration, exiting...'
            exit()

        self.likelihood = 0
        self.state_config = state_config
        self.learning_rule = learning_rule
        self.reward_function = reward_function
        self.n_actions = 2
        self.n_states = 0 if state_config == constants.STATELESS else 2
        self.initial_action_value = 0
        self.accumulated_payoffs = 0
        self.current_state = 0

        # initialise structure to store state-action values
        if self.state_config == constants.STATELESS:
            self.action_values = [self.initial_action_value for act_i in xrange(self.n_actions)]
        else:   # two-state case (both latest transaction or full history)
            self.action_values = [[self.initial_action_value for act_i in xrange(self.n_actions)] for state_i in xrange(self.n_states)]

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
        # implements softmax action selection rule according to the state space configuration
        # uses the resulting  action_log_probability to update the likelihood of the agent

        denominator = 0

        if self.state_config == constants.STATELESS:
            for act_i in xrange(self.n_actions):
                denominator += np.exp(self.beta * self.action_values[act_i])
            action_log_probability = self.beta * self.action_values[selected_action] - log(denominator)

        else:   # in case of the 2 state space configurations
            for act_i in xrange(self.n_actions):
                denominator += np.exp(self.beta * self.action_values[self.current_state][act_i])
            action_log_probability = self.beta * self.action_values[self.current_state][selected_action] - log(denominator)

        self.update_likelihood(action_log_probability)

    def get_reward(self, raw_reward):
        # updates the performance (accumulated payoffs) of the subject and
        # translates the raw reward signal (payoff) to the corresponding value of the adopted reward function

        self.update_accumulated_payoffs(raw_reward)

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

    def update_action_values(self, reward, current_action):
        # updates the action values with the processed reward value according to the learning rule
        # move to the next state

        next_state = self.get_next_state(reward)

        if self.learning_rule == constants.Q_LEARNING:
            td_error = reward + self.gamma * max(self.action_values[next_state]) - self.action_values[self.current_state][current_action]
            self.action_values[self.current_state][current_action] += self.alpha * td_error

        elif self.learning_rule == constants.AVG_TRACKING:
            if self.state_config == constants.STATELESS:
                self.action_values[current_action] += self.alpha * (reward - self.action_values[current_action])
            else:
                self.action_values[self.current_state][current_action] += self.alpha * (reward - self.action_values[self.current_state][current_action])
        self.current_state = next_state

    def get_next_state(self, reward):
        # returns the next state depending on the state-space configuration of the model
        # TODO make state values constants, at the moment 0 for profit/gain and 1 for deficit/loss

        if self.state_config == constants.STATELESS:
            return constants.GAIN

        elif self.state_config == constants.FULL_HISTORY:
            # in the full history configuration return state 0 when in profit, 1 in loss
            return constants.PROFIT if self.accumulated_payoffs >= 0 else constants.DEFICIT

        elif self.state_config == constants.LATEST_OUTCOME:
            # in the latest outcome configuration return state 0 when last payoff was profit, 1 otherwise
            return constants.GAIN if reward >= 0 else constants.LOSS


if __name__ == '__main__':

    greedy_theta = (0.4, 0.1, 0.9)
    random_theta = (0.4, 0.01, 0.9)

    greedy_agent = Agent(greedy_theta, state_config='latest_outcome', learning_rule='q_learning', reward_function='identity')
    random_agent = Agent(random_theta, state_config='latest_outcome', learning_rule='q_learning', reward_function='identity')

    '''Greedy choices'''
    choices = [0,   1,  1,  1, 0, 1,  1,  0, 0,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1, 1]
    rewards = [10, 20, 15, 12, 5, 12, 10, 5, 7, 12,  6, 12, 10, 11, 20, 12, 10, 11, 12, 20]

    for trial_i in xrange(len(choices)):
        action = choices[trial_i]
        outcome = rewards[trial_i]

        greedy_agent.select_action(action)
        greedy_agent.update_action_values(outcome, action)

    print 'greedy_agent greedy_choices: ' + str(greedy_agent.likelihood)

    for trial_i in xrange(len(choices)):
        action = choices[trial_i]
        outcome = rewards[trial_i]

        random_agent.select_action(action)
        random_agent.update_action_values(outcome, action)

    print 'random_agent greedy_choices: ' + str(random_agent.likelihood)

    '''Random choices'''
    choices = [0,   1, 0,  1, 0, 0,  1, 0,  1,  0,  1, 0,  1,  1, 0,  1, 0,  1,  1, 0]
    rewards = [10, 20, 7, 12, 5, 6, 12, 5, 11, 10, 10, 7, 12, 13, 6, 12, 9, 11, 12, 6]

    for trial_i in xrange(len(choices)):
        action = choices[trial_i]
        outcome = rewards[trial_i]

        greedy_agent.select_action(action)
        greedy_agent.update_action_values(outcome, action)

    print 'greedy_agent random_choices: ' + str(greedy_agent.likelihood)

    for trial_i in xrange(len(choices)):
        action = choices[trial_i]
        outcome = rewards[trial_i]

        random_agent.select_action(action)
        random_agent.update_action_values(outcome, action)

    print 'random_agent random_choices: ' + str(random_agent.likelihood)


