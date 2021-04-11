import matplotlib.pyplot as plt
import numpy as np

from test_functions import ackley_fn, himmelblau_fn, rastrigin_fn, rosenbrock_fn


def plot_results(results):

    #--------Test functions plot--------

    #Generate functions points

    functions = {
                "Ackley" : [[],[],[]],
                "Himmelblau" : [[],[],[]],
                "Rastrigin" : [[],[],[]],
                "Rosenbrock" : [[],[],[]]
                }

    for i in range(-60, 60):
        for j in range(-60, 60):
            functions['Ackley'][0].append(i)
            functions['Ackley'][1].append(j)
            functions['Ackley'][2].append(ackley_fn((i/10, j/10)))
            
            functions['Himmelblau'][0].append(i)
            functions['Himmelblau'][1].append(j)
            functions['Himmelblau'][2].append(himmelblau_fn((i/10, j/10)))
                    
            functions['Rosenbrock'][0].append(i)
            functions['Rosenbrock'][1].append(j)
            functions['Rosenbrock'][2].append(rosenbrock_fn((i/10, j/10)))

    for i in range(-512, 512, 10):
        for j in range(-512, 512, 10):
                    
            functions['Rastrigin'][0].append(i)
            functions['Rastrigin'][1].append(j)
            functions['Rastrigin'][2].append(rastrigin_fn((i/100, j/100)))

    fig = plt.figure( figsize = (20,10))

    #Ackley function
    ax1 = fig.add_subplot(221, projection='3d', title = 'Ackley')
    xs = functions['Ackley'][0]
    ys = functions['Ackley'][1]
    zs = functions['Ackley'][2]
    ax1.scatter(xs, ys, zs, marker='o')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('energy')

    #Himmelblau function
    ax2 = fig.add_subplot(222, projection='3d', title = 'Himmelblau')
    xs = functions['Himmelblau'][0]
    ys = functions['Himmelblau'][1]
    zs = functions['Himmelblau'][2]
    ax2.scatter(xs, ys, zs, marker='o')
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_zlabel('energy')

    #Rastrigin function
    ax3 = fig.add_subplot(223, projection='3d', title = 'Rastrigin')
    xs = functions['Rastrigin'][0]
    ys = functions['Rastrigin'][1]
    zs = functions['Rastrigin'][2]
    ax3.scatter(xs, ys, zs, marker='o')
    ax3.set_xlabel('x')
    ax3.set_ylabel('y')
    ax3.set_zlabel('energy')

    #Rosenbrock function
    ax4 = fig.add_subplot(224, projection='3d', title = 'Rosenbrock')
    xs = functions['Rosenbrock'][0]
    ys = functions['Rosenbrock'][1]
    zs = functions['Rosenbrock'][2]
    ax4.scatter(xs, ys, zs, marker='o')
    ax4.set_xlabel('x')
    ax4.set_ylabel('y')
    ax4.set_zlabel('energy')

    plt.savefig("./images/test_fn.png")
    #------------Results plot-----------------

    #Organize the results of the performance tests

    #Ackley
    Ackley_points = np.array(results['Ackley'][0])
    Ackley_energy = np.array(results['Ackley'][1])
    Ackley_temp = np.array(results['Ackley'][2])

    #Himmelblau
    Himm_points = np.array(results['Himmelblau'][0])
    Himm_energy = np.array(results['Himmelblau'][1])
    Himm_temp = np.array(results['Himmelblau'][2])

    #Rastrigin
    Rastr_points = np.array(results['Rastrigin'][0])
    Rastr_energy = np.array(results['Rastrigin'][1])
    Rastr_temp = np.array(results['Rastrigin'][2])

    #Rosenbrock
    Rosen_points = np.array(results['Rosenbrock'][0])
    Rosen_energy = np.array(results['Rosenbrock'][1])
    Rosen_temp = np.array(results['Rosenbrock'][2])

    fig = plt.figure( figsize = (20,10))
    #Ackley plot
    ax1 = fig.add_subplot(221, projection='3d', title = 'Ackley test')
    xs = Ackley_points[:,0]
    ys = Ackley_points[:,1]
    zs = Ackley_energy
    ax1.scatter(xs, ys, zs, marker='o', color = 'green', label = "data points")
    ax1.scatter(xs[0],ys[0],zs[0], color = 'red', marker = '*', s = 100, label = "initial point")
    ax1.scatter(0.,0.,0., marker='^', s = 100, color = 'black', label = "global minimum")
    ax1.legend()
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('energy')

    #Himmelblau plot
    ax2 = fig.add_subplot(222, projection='3d', title = 'Himmelblau test')
    xs = Himm_points[:,0]
    ys = Himm_points[:,1]
    zs = Himm_energy
    ax2.scatter(xs, ys, zs, marker='o', color = 'green', label = "data points")
    ax2.scatter(xs[0],ys[0],zs[0], color = 'red', marker = '*', s = 100, label = "initial point")
    ax2.scatter([3,-2.805118, -3.779310, 3.584428], [2, 3.131312,-3.283186,-1.848126],[0.,0.,0.,0.], 
                marker='^', s = 100, color = 'black', label = "global minima")
    ax2.legend()
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_zlabel('energy')

    #Rastrigin plot
    ax3 = fig.add_subplot(223, projection='3d', title = 'Rastrigin test')
    xs = Rastr_points[:,0]
    ys = Rastr_points[:,1]
    zs = Rastr_energy
    ax3.scatter(xs, ys, zs, marker='o', color = 'green', label = "data points")
    ax3.scatter(xs[0],ys[0],zs[0], color = 'red', marker = '*', s = 100, label = "initial point")
    ax3.scatter(0.,0.,0., marker='^', s = 100, color = 'black', label = "global minimum")
    ax3.legend()
    ax3.set_xlabel('x')
    ax3.set_ylabel('y')
    ax3.set_zlabel('energy')

    #Rosenbrock plot
    ax4 = fig.add_subplot(224, projection='3d', title = 'Rosenbrock test')
    xs = Rosen_points[:,0]
    ys = Rosen_points[:,1]
    zs = Rosen_energy
    ax4.scatter(xs, ys, zs, marker='o', color = 'green', label = "data points")
    ax4.scatter(xs[0],ys[0],zs[0], color = 'red',marker = '*', s = 100, label = "initial point")
    ax4.scatter(1.,1.,0., marker='^', s = 100, color = 'black', label = "global minimum")
    ax4.legend()
    ax4.set_xlabel('x')
    ax4.set_ylabel('y')
    ax4.set_zlabel('energy')

    plt.savefig("./images/results.png")
    plt.show()

    
