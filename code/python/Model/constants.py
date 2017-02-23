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
TANH = 'tanh'
PT_VALUE_FUNC = 'pt_value_func'

# prospect theory value function factor and loss aversion
PT_FACTOR = 0.88
PT_LOSS_AVERSION = 2.25

# tanh squash factor
TANH_OMEGA = 500  # TODO decide this value depending on the outcome data spread

# tanh new range
TANH_NEW_RANGE = 50  # TODO decide this value depending on the outcome data spread

# file paths    # TODO make these absolute and not relative (won't work when calling from different folders)
DATA_FILE_PATH = '../../data/'
RESULTS_FILE_PATH = '../../results/'
