 # %%
#-----------Set the environment---------------
import sys, os

import matplotlib.pyplot as plt
import numpy as np
from numpy import random as rnd

sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../Eleonora_Misino-Project_2020")
from plot import plot_results
from simulated_annealing import SA, geom_cooling, boltz_acceptance_prob, boltz_move
from test_functions import ackley_fn, rastrigin_fn, rosenbrock_fn, himmelblau_fn

rnd.seed(42)

 # %%
#--------Set the test configuration---------
test_conf = {
    "Ackley" : [ackley_fn, (-6, 6), 100. ],
    "Himmelblau" : [himmelblau_fn, (-6, 6), 100. ],
    "Rastrigin" : [rastrigin_fn, (-5.12, 5.12), 100. ],
    "Rosenbrock" : [rosenbrock_fn, (-6, 6), 100. ]
}
results = {
    "Ackley" : [],
    "Himmelblau" : [],
    "Rastrigin" : [],
    "Rosenbrock" : []
}
exit_interations = {
    "Ackley" : [],
    "Himmelblau" : [],
    "Rastrigin" : [],
    "Rosenbrock" : []
} 

# %%
#------------------Run the algorithm---------------
for fn, par in test_conf.items():
    states, energies, temp, k, _exit, reann = SA(   cooling = geom_cooling,
                                                    acceptance_prob = boltz_acceptance_prob,
                                                    energy = par[0],
                                                    move = boltz_move,
                                                    interval = par[1],
                                                    initial_temp = par[2],
                                                    k_max = 10000,
                                                    tolerance_value = 1e-10,
                                                    tolerance_iter = 1000,
                                                    obj_fn_limit = 1e-10,
                                                    reann_tol = 100,
                                                    verbose = True
                                                    )
    results[fn].append(states)
    results[fn].append(energies)
    results[fn].append(temp)
    exit_interations[fn].append(_exit)
    exit_interations[fn].append(k)
    exit_interations[fn].append(reann)

# %%
#--------Plot results---------
for k,v in exit_interations.items():
    print("\n")
    print("Function: {}\nStopping criterion: {}\nNumber of iteration: {}\nReannling: {}".format(k,v[0],v[1], v[2]))

plot_results(results)


