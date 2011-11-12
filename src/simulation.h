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

      // current time of the simulation
      int current_time;

      // the last running pid and tid, and how many context switches have
      // occured since the last running state
      // during a multi-step context switch, the last_* variabels are set to
      // the new pid and tid after the first context switch
      int last_pid;
      int last_tid;
      int context_delay;

      // create a blank simulation
      Simulation(int thread_overhead, int process_overhead);

      // create a simulation from a specification
      Simulation(std::ifstream &file);
};

#endif
