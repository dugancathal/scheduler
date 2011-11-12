#include "simulation.h"

#include "burst.h"
#include "process.h"
#include "thread.h"

Simulation::Simulation(int thread_overhead, int process_overhead)
{
   this->thread_overhead = thread_overhead;
   this->process_overhead = process_overhead;
}

Simulation::Simulation(std::ifstream &file)
{
   if(!file.is_open())
   {
      // file is not open - cannot read
      return;
   }

   int num_processes;
   file >> num_processes;
   file >> this->thread_overhead;
   file >> this->process_overhead;

   for(int process = 0; process < num_processes; process++)
   {
      // create the process
      int pid;
      int num_threads;

      file >> pid;
      file >> num_threads;

      Process *p = new Process(pid);

      // retrieve the values for each thread
      for(int thread = 0; thread < num_threads; thread++)
      {
         int arrival_time;
         int num_bursts;

         file >> arrival_time;
         file >> num_bursts;

         Thread *t = new Thread(arrival_time, p, thread);

         // retrieve the values for each burst
         bool burst_type_cpu = true;
         for(int burst = 0; burst < num_bursts * 2 - 1; burst++)
         {
            int burst_length;
            file >> burst_length;

            Burst *b;

            if(burst_type_cpu)
            {
               b = new Burst(CPU, burst_length);
            }
            else
            {
               b = new Burst(IO, burst_length);
            }

            burst_type_cpu = !burst_type_cpu;

            t->bursts.push_back(b);
         }

         // done processing the bursts
         // add the thread to the process
         p->threads.push_back(t);
      }

      // done processing all threads for the process
      // save the process in the simulation
      this->processes[pid] = p;
   }
}
