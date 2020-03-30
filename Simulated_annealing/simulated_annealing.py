import numpy as np
from numpy import random as rnd

#-------Neighbour generation----------

def boltz_move(state, temp, interval):
    """
    The step length equals the square root of the current temperature.
    The direction is uniformly random.
    """
    
    new_state = [0,0]
    n = rnd.random()
    if n < 0.5 :
        new_state[0] = state[0] + np.sqrt(temp)
        new_state[1] = state[1] + np.sqrt(temp)
        return (clip(new_state[0], interval, state[0]), 
                clip(new_state[1], interval, state[1]))
    else :
        new_state[0] = state[0] - np.sqrt(temp)
        new_state[1] = state[1] - np.sqrt(temp)
        return (clip(new_state[0], interval, state[0]), 
                clip(new_state[1], interval, state[1]))


def clip(x, interval, state):
    """
    If x is not in interval, 
    return a point chosen uniformly at random between the violated bound 
    and the previous state; 
    otherwise return x.
    """
    
    a,b = interval   
    if x < a :
        return rnd.uniform(a, state)    
    if x > b :
        return rnd.uniform(state, b)    
    else: 
        return x
    


#---------Acceptance function--------------

def boltz_acceptance_prob(energy, new_energy, temperature):
    """Boltzmann Annealing"""
    
    delta_e = new_energy - energy   
    if delta_e < 0 :
        return 1
    else:
        return np.exp(- delta_e / temperature)


#--------Cooling Procedures---------------

def boltz_cooling(initial_temp, k):
    """Boltzmann temperature decreasing."""
    if k <= 1:
        return initial_temp
    else:
        return initial_temp / np.log(k)

def geom_cooling(temp, k,  alpha = 0.95):
    """Geometric temperature decreasing."""
    return temp * alpha

#--------Stopping Condition------------

def tolerance(energies, tolerance, tolerance_iter) :
    """
    The algorithm runs until the average change in value of the objective function 
    is less than the tolerance.
    """
    
    if len(energies) <= tolerance_iter :
        return False
    if avg_last_k_value(energies, tolerance_iter) < tolerance :
        return True
    else : 
        return False
    
def objective_limit(energy, limit):
    """
    The algorithm stops as soon as the current objective function value
    is less or equal then limit.
    """
    
    if energy <= limit :
        return True
    else :
        return False


def avg_last_k_value(energies, k):
    """
    Compute the average of the last k absolute differences between the values of a list.
    """
    
    diff = []
    L = len(energies)    
    for i in range(L - 1,L - (k+1),-1):
        diff.append(abs(energies[i]-energies[i-1]))
    return np.mean(diff)



#------------------------------------------------------
#------------Simulated Anneanling algorithm------------
#------------------------------------------------------

def SA(cooling, acceptance_prob, energy, move, interval, initial_temp = 100., 
       k_max = 1e10, tolerance_value = 1e-6, tolerance_iter = 10,
       obj_fn_limit = -1e10, reann_tol = 100, verbose = False):
    
    #Step 1
    states = []
    energies = []
    temperatures = []
    s = (rnd.uniform(interval[0], interval[1]), rnd.uniform(interval[0], interval[1]))
    k = 0
    T = initial_temp
    reann = False
    exit_types = {0 :'Max Iter',
            1 : 'Tolerance',
            2 : 'Obj Limit',
            3 : 'Temp Limit'}
    _exit = 0
    
    if verbose:
        dash = '-' * 70
        print("\n")
        print ('{:_^70}'.format('Simulated Annealing'))
        print("Test function", energy)
        print("Initial state: {}".format(s))
        print("\n")
    
    
    while True:
        k += 1
        
        #Stopping criterion
        if k == k_max :
            if verbose :
                print(dash)
                print("MAX ITERATION EXIT")
                print(dash)
            break           
        
        #Step 2
        new_s = move(s, T, interval)
        energy_s = energy(s)
        energy_new_s = energy(new_s)
        states.append(s)
        energies.append(energy_s)
        temperatures.append(T)
        
        #Step 3
        T = cooling(T, k)
        
        #Stopping criteria
        if T <= 0. :
            if verbose :
                print(dash)
                print("TEMPERATURE EXIT")
                print(dash)
            _exit = 3
            break   
        
       
        if tolerance(energies, tolerance_value, tolerance_iter) :
            if verbose :
                print(dash)
                print("TOLERANCE EXIT")
                print(dash)
            _exit = 1
            break    
        
        
        if objective_limit(energy_s, obj_fn_limit) :
            if verbose :
                print(dash)
                print("OBJECTIVE FUNCTION LIMIT EXIT")
                print(dash)
            _exit = 2
            break
        
        #Reanniling Process
        best_e = min(energies)
        best_s = states[np.argmin(energies)]
        
        if energy_s > best_e + reann_tol :
            if verbose :
                print(dash)
                print("REANNILING")
                print(dash)
            s = best_s
            energy_s = best_e
            T = initial_temp
            k = 0
            reann = True
            continue
        
        #Step 4
        if acceptance_prob(energy_s, energy_new_s, T) >= rnd.random() :
            s = new_s
    
    return states, energies, temperatures, k, exit_types[_exit], reann

