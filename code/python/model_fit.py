from __future__ import division
from scipy.optimize import minimize
import random


def model_run(params, *args):
    print 'params',params
    print 'args',args
    # x,y = params
    # test = args
    # print test
    raw_input()
    print 'running model with params {} {}'.format(x,y)
    print 'RL magic..'
    NLL = 4#  (x-50)**2 + (y+60)**2 #(20*x-50)**2 + (20*y+60)**2 + 200
    #print 'calculate Negative Log Likelihood (Max Likelihood Estimate):',NLL
    print NLL
    return NLL


def fit(subject, prob_id):

    # alpha, beta and gamma bounds
    bounds = ((0,1),(0,50),(0,1))
    gps = [(0,0,0),(0,0,0.5),(0,0,1),(0,0.5,0),(0,0.5,0.5),(0,0.5,1),(0,1,0),(0,1,0.5),(0,1,1),
           (0.5,0,0),(0.5,0,0.5),(0.5,0,1),(0.5,0.5,0),(0.5,0.5,0.5),(0.5,0.5,1),(0.5,1,0),(0.5,1,0.5),(0.5,1,1),
           (1,0,0),(1,0,0.5),(1,0,1),(1,0.5,0),(1,0.5,0.5),(1,0.5,1),(1,1,0),(1,1,0.5),(1,1,1)]

    minNLL = 9999
    params = []

    for gp in gps:
        print '\ngrad desc with guess points {}'.format(gp)
        minimisation_results = minimize(model_run, gp, args=(subject,prob_id), bounds=bounds, tol=1e-18)
        print
        if minimisation_results['success'] and minimisation_results['fun'] < minNLL:
            minNLL = minimisation_results['fun']
            params = list(minimisation_results['x'])
        else:
            pass

    return minNLL,params


if __name__ == '__main__':
    pass
    # print 'initialising boundaries and guess points'
    # bounds = ((-100,100),(-100,100))
    # gps = [(-80,-80),(-80,0),(0,-80),(0,0),(0,80),(80,0),(80,80)]
    # NLL, params = fit(bounds,gps)
    # print 'NLL = ',NLL
    # print 'params = ',params