#ifndef SIMULATION_H
#define SIMULATION_H

#include <map>
#include <iostream>
#include <fstream>

class Process;

class Simulation
{
   public:
      // all processes
      // map of pid -> process
      std::map<int, Process*> processes;

      // thread overheads for context switching
      int thread_overhead;
      int process_overhead;

      // create a blank simulation
      Simulation(int thread_overhead, int process_overhead);

      // create a simulation from a specification
      Simulation(std::ifstream &file);
};

#endif
