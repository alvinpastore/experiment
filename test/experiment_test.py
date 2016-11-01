import numpy as np

trials = 50
responses = []
dist1_mean = 100
dist1_std = 354
dist2_mean = 25
dist2_std = 17.7

for trial in xrange(trials):
    print '\ntrial ' + str(trial)
    choice = raw_input('A or B? ') # choice is 'a' or 'b'
    if 'a' in choice or 'A' in choice:
        draw = np.random.normal(dist1_mean,dist1_std)

    elif 'b' in choice or 'B' in choice:
        draw = np.random.normal(dist2_mean,dist2_std)

    else:
        trial -= 2
        print 'choose a or b, no other keys allowed'
        pass

    print 'outcome: ' + str(draw)
    responses.append((choice,draw))

with open('test.csv','w') as out_file:
    for response in responses:
        out_file.write(str(response[0]) + ',' + str(response[1]) + '\n')


