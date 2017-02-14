# state space configurations
STATELESS = 'stateless'
FULL_HISTORY = 'full_history'
LATEST_OUTCOME = 'latest_outcome'

# state codes
PROFIT = 0
GAIN = 0
DEFICIT = 1
LOSS = 1

# learning rules
Q_LEARNING = 'q_learning'
AVG_TRACKING = 'avg_tracking'

# reward functions
IDENTITY = 'identity'
HTAN = 'htan'
PT_VALUE_FUNC = 'pt_value_func'

# prospect theory value function factor and loss aversion
PT_FACTOR = 0.88
PT_LOSS_AVERSION = 2.25

# htan factor
HTAN_FACTOR = 15 #TODO decide this value depending on the outcome data spread