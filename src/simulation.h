#ifndef SIMULATION_H
#define SIMULATION_H

#include <fstream>
#include <map>
#include <queue>

#include "event.h"

class Process;

class Simulation
{
   public:
      // all processes
      // map of pid -> process
      std::map<int, Process*> processes;

      // events, where the priority is the time (soonest first)
      std::priority_queue<Event*, std::vector<Event*>, CompareEvent> events;

      // thread overheads for context switching
      int thread_overhead;
      int process_overhead;

      // create a blank simulation
      Simulation(int thread_overhead, int process_overhead);

      // create a simulation from a specification
      Simulation(std::ifstream &file);
};

#endif
