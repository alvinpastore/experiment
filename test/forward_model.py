from __future__ import division
from math import log
import numpy as np
import random



def get_next_state(wealth, last_reward):
    # wealth is the profit up to this moment (calculated as sum of rewards)
    if states_type == 'profit':
        if wealth < 0:
            return 0  # poor if profit (accumulated with sales) is negative
        else:
            return 1  # rich if profit is positive (or 0)
    elif states_type == 'reward':
        if last_reward < 0:
            return 0  # negative if last transaction was negative
        else:
            return 1  # positive if last transaction was positive or 0

def routine(params):
    trials = 50
    responses = []
    dist1_mean = 100
    dist1_std = 354
    dist2_mean = 25
    dist2_std = 17.7

    alpha, beta, gamma, scaling_factor = params

    n_actions = 2
    n_states = 2
    Q = [[0 for x in xrange(n_actions)] for x in xrange(n_states)]
    profit = 0
    state = 0

    for trial in xrange(trials):
        # print '\ntrial ' + str(trial)

        # softmax
        denominator = 0
        for a in xrange(n_actions):
            denominator += np.exp(beta * Q[state][a])

        # probability of picking action a
        # needs to be exponentiated because
        # while MLE is the logarithm of a probability (and then summed)
        # in this case we need the probability
        prob_a = np.exp(beta * Q[state][0] - log(denominator))

        if random.uniform(0, 1) > prob_a:
            reward = np.random.normal(dist1_mean,dist1_std)
            action = 0
            # print 'choose a'
        else:
            reward = np.random.normal(dist2_mean,dist2_std)
            action = 1
            # print 'choose b'

        #print 'outcome: ' + str(reward)
        responses.append((action,reward))

        # observe next state
        if n_states > 1:
            next_state = get_next_state(profit, reward)
        else:
            next_state = 0

        #print Q
        # update rule
        TD_error = (reward + (gamma * max(Q[next_state])) - Q[state][action])
        Q[state][action] += alpha * TD_error

        # move to next state
        state = next_state

    return responses
    #
    # with open('test.csv','w') as out_file:
    #     for response in responses:
    #         out_file.write(str(response[0]) + ',' + str(response[1]) + '\n')
    #

if __name__ == '__main__':
    states_type = 'profit'
    params = [0.98999999999999988, 2.6144599885791155, 0.39974034993683588, 54.560018340551849]

    responses_matrix = []
    iterations = 1000

    for iteration in xrange(iterations):
        responses_matrix.append(routine(params))

    avg_choices = [0] * iterations

    for responses in responses_matrix:
        choices, returns = zip(*responses)

        for choice_index in xrange(50):
            avg_choices[choice_index] += choices[choice_index]

    avg_choices = [x / iterations for x in avg_choices]

    for avg_choice in avg_choices:
        print avg_choice