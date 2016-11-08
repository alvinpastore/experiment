from __future__ import division
from scipy.optimize import minimize
import numpy as np
from math import log
import time

def get_next_state(acc_ret,reward):
    # #TODO extend to different types of states
    # if acc_ret < 0:
    #     return 0 # poor
    # else:
    #     return 1 # rich
    return 0


def PT_value_function(outcome):
    PT_factor = 0.88
    PT_loss_aversion = 2.25
    if outcome > 0:
        return outcome**PT_factor
    elif outcome < 0:
        return -PT_loss_aversion * ((-outcome)**PT_factor)
    else:
        return outcome

def Q_learning_model_run(params, *args):

    alpha,beta,gamma = params
    #gamma = 0 #TODO gamma = 0
    subject, prob_id, nActions, nStates = args
    # print
    # print 'subject',subject.subject_id
    # print 'problem',prob_id
    # print 'a:{} b:{} g:{}'.format(alpha,beta,gamma)

    if subject.subject_id != 12:
        return -1

    #initialisation
    Q = [[0 for acts in xrange(nActions)] for stts in xrange(nStates)]
    state = 0
    NLL = 0
    accumulated_return = 0
    trials = subject.get_trials(prob_id)

    for trial in trials:
        #print 'trial {}, action {}, outcome {}'.format(trial.id,trial.choice,trial.outcome)
        action = trial.choice - 1 # -1 as the original choices are in {1,2}

        # softmax action selection
        denominator = 0
        for a in xrange(nActions):
            denominator += np.exp(beta * Q[state][a])
        act_probability = beta * Q[state][action] - log(denominator)
        NLL += act_probability

        reward = trial.outcome
        accumulated_return += reward
        reward = PT_value_function(reward)

        next_state = get_next_state(accumulated_return, trial.outcome)

        # update rule
        TD_Error = reward + gamma * max(Q[next_state]) - Q[state][action]
        Q[state][action] += alpha * TD_Error

        state = next_state

    #print -NLL
    return -NLL



def fit(subject, prob_id, nActions, nStates, **kwargs):
    ti = time.time()
    # alpha, beta and gamma bounds and guess points
    #bounds = ((0,1),(0,50),(0,1))
    # gps = [(0,0,0),(0,0,0.5),(0,0,1),(0,0.5,0),(0,0.5,0.5),(0,0.5,1),(0,1,0),(0,1,0.5),(0,1,1),
    #        (0.5,0,0),(0.5,0,0.5),(0.5,0,1),(0.5,0.5,0),(0.5,0.5,0.5),(0.5,0.5,1),(0.5,1,0),(0.5,1,0.5),(0.5,1,1),
    #        (1,0,0),(1,0,0.5),(1,0,1),(1,0.5,0),(1,0.5,0.5),(1,0.5,1),(1,1,0),(1,1,0.5),(1,1,1)]
    bounds = ((0.0001,0.2),(0.1,2),(0.0,1))
           #alpha   #beta   #gamma
    gps = [(0.0001  ,0.1    ,0),
           (0.0001  ,0.1    ,0.5),
           (0.0001  ,0.1    ,0.7),
           (0.0001  ,0.5    ,0),
           (0.0001  ,0.5    ,0.5),
           (0.0001  ,0.5    ,0.7),
           (0.1     ,0.1    ,0),
           (0.1     ,0.1    ,0.5),
           (0.1     ,0.1    ,0.7),
           (0.1     ,0.5    ,0),
           (0.1     ,0.5    ,0.5),
           (0.1     ,0.5    ,0.7),
           (0.0001  ,1      ,0),
           (0.0001  ,1      ,0.5),
           (0.0001  ,1      ,0.7),
           (0.0001  ,2      ,0),
           (0.0001  ,2      ,0.5),
           (0.0001  ,2      ,0.7),
           (0.1     ,1      ,0),
           (0.1     ,1      ,0.5),
           (0.1     ,1      ,0.7),
           (0.1     ,2      ,0),
           (0.1     ,2      ,0.5),
           (0.1     ,2      ,0.7)]

    minNLL = 9999
    params = []

    for gp in gps:
        if 'verbose' in kwargs:
            print '\ngrad desc with guess points {}'.format(gp)
        minimisation_results = minimize(Q_learning_model_run, gp, args=(subject, prob_id, nActions, nStates), bounds=bounds, method='TNC', tol=1e-18)

        if 'verbose' in kwargs:
            print minimisation_results
            print

        if minimisation_results['success'] and minimisation_results['fun'] < minNLL:
            minNLL = minimisation_results['fun']
            params = list(minimisation_results['x'])
        else:
            pass
    print str(time.time() - ti) + ' seconds'
    return minNLL,params


if __name__ == '__main__':
    pass
    # print 'initialising boundaries and guess points'
    # bounds = ((-100,100),(-100,100))
    # gps = [(-80,-80),(-80,0),(0,-80),(0,0),(0,80),(80,0),(80,80)]
    # NLL, params = fit(bounds,gps)
    # print 'NLL = ',NLL
    # print 'params = ',params