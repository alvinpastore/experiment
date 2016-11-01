from __future__ import division
from scipy.optimize import minimize
import csv
import numpy as np
from math import log
import time


file_name = 'test.csv'
with open(file_name,'r') as f:
    r = csv.reader(f)
    responses = [(row[0],row[1]) for row in r if row]

choices, returns = zip(*responses)
returns = map(float,returns)

sorted_returns = sorted(returns)
for ret in sorted_returns:
    print ret
#print 'min: ' + str(min(returns)) + "  max: " + str(max(returns))