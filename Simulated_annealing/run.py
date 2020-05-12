
#-----------Set the environment---------------
import sys, os
import argparse

import matplotlib.pyplot as plt
import numpy as np
from numpy import random as rnd

from plot import plot_results
from algorithm import SA, geom_cooling, boltz_acceptance_prob, boltz_move
from test_functions import ackley_fn, rastrigin_fn, rosenbrock_fn, himmelblau_fn

#rnd.seed(42)

if __name__ == '__main__':

    #---------------Parser----------------

    parser = argparse.ArgumentParser(description='Simulated Annealing Algorithm', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-t', '--init_temp', action='store', nargs='?', const=None, default=100, type=float,
                        choices=None, help='Initial temperature. [default: 100]', metavar=None)
    parser.add_argument('-k', '--k_max', action='store', nargs='?', const=None, default=1e6, type=int,
                        choices=None, help='Max number of iterations. [default: 1e6]', metavar=None)
    parser.add_argument('-tv', '--tolerance_value', action='store', nargs='?', const=None, default=1e-6, type=float,
                        choices=None, help='Tolerance Energy value for stopping criterion [default: 1e-6]', metavar=None)
    parser.add_argument('-ti', '--tolerance_iter', action='store', nargs='?', const=None, default=1000, type=int,
                        choices=None, help='Number of iterations taken into account in Tolerance Energy. [default: 1000]', metavar=None)
    parser.add_argument('-o', '--obj_fn_limit', action='store', nargs='?', const=None, default=-1e10, type=float,
                        choices=None, help='Objective function limit. [default: -1e10]', metavar=None)
    parser.add_argument('-r', '--reann', action='store', nargs='?', const=None, default=100, type=float,
                        choices=None, help='Reanniling tolerance value.[default: 100]', metavar=None)
    parser.add_argument('-v', '--verbose', action='store', nargs='?', const=None, default=False, type=bool,
                        choices=None, help='[default: False]', metavar=None)
    args = parser.parse_args()
    
    #--------Set the test configuration---------

    test_conf = {
        "Ackley" : [ackley_fn, (-6, 6) ],
        "Himmelblau" : [himmelblau_fn, (-6, 6)],
        "Rastrigin" : [rastrigin_fn, (-5.12, 5.12)],
        "Rosenbrock" : [rosenbrock_fn, (-6, 6)]
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
    
    
    #------------------Run the algorithm---------------
    for fn, par in test_conf.items():
        states, energies, temp, k, _exit, reann = SA(   cooling = geom_cooling,
                                                        acceptance_prob = boltz_acceptance_prob,
                                                        energy = par[0],
                                                        move = boltz_move,
                                                        interval = par[1],
                                                        initial_temp = args.init_temp,
                                                        k_max = args.k_max,
                                                        tolerance_value = args.tolerance_value,
                                                        tolerance_iter = args.tolerance_iter,
                                                        obj_fn_limit = args.obj_fn_limit,
                                                        reann_tol = args.reann,
                                                        verbose = args.verbose
                                                        )
        results[fn].append(states)
        results[fn].append(energies)
        results[fn].append(temp)
        exit_interations[fn].append(_exit)
        exit_interations[fn].append(k)
        exit_interations[fn].append(reann)
    
    
    #--------Plot results---------
    for k,v in exit_interations.items():
        print("\n")
        print("Function: {}\nStopping criterion: {}\nNumber of iterations: {}\nReanniling: {}".format(k,v[0],v[1], v[2]))
    
    plot_results(results)
    
    
