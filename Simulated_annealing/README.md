# Simulated Annealing 
Simulated Annealing is a project realized as part of the *Combinatorial Decision Making and Optimization* exam of the [Master's degree in Artificial Intelligence,  University of Bologna](https://corsi.unibo.it/2cycle/artificial-intelligence).

The aim of this project is to test the **Simulated Annealing** technique on different test functions.

The implemented SA algorithm  works in a 2-dimensional space using the **Boltzmann acceptance probability function** and the **Geometric Cooling Schedule**. 

The candidate **new solution** is generated starting from the current solution and moving in a random direction by a quantity proportional to the square root of the temperature. 

The implemented **stopping criteria** are the following:
* *Max Iteration*
* *Temperature Lower Bound*
* *Energy Lower Bound*
* *Energy Tolerance*

## Available test functions

* *Ackely function*
* *Himmelblau function*
* *Rosenbrock function*
* *Rastrigin function*
![Test Functions](https://github.com/EleMisi/TinyProjects/blob/master/Simulated_annealing/images/test_fn.png)
## Run the tests
1. Clone the repository
2. On a terminal run:
    ```
    python run.py 
    ```
    with optional arguments 
    * `-t` : `Float` -> Initial temperature. [default: 100]
    * `-k` : `Int` -> Max number of iterations. [default: 1e6]
    * `-tv`: `Float` -> Tolerance Energy value for stopping criterion [default: 1e-6]
    * `-ti` : `Int` -> Number of iterations taken into account in Tolerance Energy. [default: 1000]
    * `-o`: `Float` -> Objective function limit. [default: -1e10]
    * `-r`: `Float`  -> Reanniling tolerance value.[default: 100]
    * `-v` : `Bool` -> Verbose parameter, [default: False]

## Results
In the figure below I report the results of a running with the default configuration.

As you can see, the algorithm easily converges in Himmelblau’s test, while it shows some difficulties with *Ackley* and *Rastrigin* functions: the high number of local minima slows down the search. 

It’s also interesting to observe the algorithm behaviour in *Rosenbrock* test: the test function is very flat and so SA is unable to reach the global minimum before the *Energy Tolerance* stopping criterion is met.
![Results](https://github.com/EleMisi/TinyProjects/blob/master/Simulated_annealing/images/results.png)

### Built With

* [Python 3.7](https://www.python.org/downloads/release/python-370/)


### Author

* [EleMisi](https://github.com/EleMisi)


### License

This project is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/EleMisi/TinyProjects/blob/master/LICENSE) file for details.

### References
* Holger H. Hoos, Thomas Stützle, Stochastic Local Search, 2005
* Henderson, Darrall & Jacobson, Sheldon & Johnson, Alan. (2006). The Theory and Practice of Simulated Annealing. . 

### External links
* Simulated Annealing project on my [website](https://eleonoramisino.altervista.org/simulated-annealing/).


