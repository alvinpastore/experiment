from __future__ import division
from scipy.optimize import minimize
import csv
import numpy as np
from math import log
import time


def htan_custom(xx, factor):
    return (1 - np.exp(- xx * factor)) / (1 + np.exp(- xx * factor))


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


def model_fit(parameters, *args):

    alpha, beta, gamma, scaling_factor = parameters

    Q = [[0 for x in xrange(n_actions)] for x in xrange(n_states)]
    profit = 0
    state = 0
    MLE = 0

    if verbose:
        print 'a: {0:5.2f}  b: {1:5.2f}  c: {2:5.2f}'.format(parameters[0],parameters[1],parameters[2])


    for response in responses:
        choice = response[0]
        reward = float(response[1])
        if verbose:
            print 'reward raw', reward
        reward = htan_custom(reward, 1 / scaling_factor)
        if verbose:
            print 'reward htan', reward

        profit += reward
        action = 0 if 'a' in response else 1
        if verbose:
            print 'action', action

        # softmax
        denominator = 0
        for a in xrange(n_actions):
            denominator += np.exp(beta * Q[state][a])
            if verbose:
                print 'denominator',denominator
        MLE += (beta * Q[state][action]) - log(denominator)

        if verbose:
            print 'current action MLE: ' + str(((beta * Q[state][action]) - log(denominator))) + '  total MLE: ' + str(MLE)

        # observe next state
        if n_states > 1:
            next_state = get_next_state(profit, reward)
        else:
            next_state = 0

        #print Q
        # update rule
        TD_error = (reward + (gamma * max(Q[next_state])) - Q[state][action])
        Q[state][action] += alpha * TD_error

        if verbose:
            print Q

        # move to next state
        state = next_state

    if verbose:
        print -MLE
        print

    return -MLE


if __name__ == '__main__':
    verbose = 0

    file_name = 'test.csv'
    with open(file_name,'r') as f:
        r = csv.reader(f)
        responses = [(row[0],row[1]) for row in r if row]

    states_type = 'profit'
    n_actions = 2
    n_states = 2

    a_min = 0.01
    a_max = 0.99
    b_min = 1
    b_max = 10
    g_min = 0
    g_max = 0.99
    scaling_factor = 100

    bounds = ((a_min,a_max), (b_min,b_max), (g_min,g_max), (1,500))

    # guess points (start of search space)
    gps = [(a_min, b_min, g_min, scaling_factor),   (a_min, b_min, g_max, scaling_factor),
           (a_min, b_max, g_min, scaling_factor),   (a_min, b_max, g_max, scaling_factor),
           (a_max, b_min, g_min, scaling_factor),   (a_max, b_min, g_max, scaling_factor),
           (a_max, b_max, g_min, scaling_factor),   (a_max, b_max, g_max, scaling_factor)]

    MLE_res = 999999
    params = []

    t1 = time.time()

    for gp in gps:
        print '*************************************************'
        print gp
        #raw_input(gp)
        # default method = BFGS, SLSQP seems better
        min_result = minimize(model_fit, gp, method='SLSQP', bounds=bounds, tol=1e-18)
        if verbose:
            print min_result

        if min_result['success'] and min_result['fun'] < MLE_res:
            #print min_result
            MLE_res = min_result['fun']
            params = list(min_result['x'])

        else:
            pass

    print MLE_res
    print params

    print 'total ' + str(time.time() - t1) + ' seconds'
