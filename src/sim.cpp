#include <iostream>
#include <cstdlib>

#include <vector>

#include "simulation.h"
#include "process.h"
#include "thread.h"
#include "burst.h"

using namespace std;

int main(int argc, char **argv)
{
   string filename;
   bool debug = false;
   bool verbose = false;

   // ensure proper number of arguments
   if(argc < 2 || argc > 4)
   {
      cerr << "USAGE: sim [-d] [-v] simulation_file" << endl;
      exit(1);
   }

   // parse arguments
   for(int arg = 1; arg < argc; arg++)
   {
      if(arg == argc - 1)
      {
         // last argument - must be filename
         filename = string(argv[arg]);
      }
      else
      {
         // not the last argument - check for switches
         if(string(argv[arg]) == "-d")
         {
            debug = true;
         }
         else if(string(argv[arg]) == "-v")
         {
            verbose = true;
         }
         else
         {
            cerr << "Unknown argument: " << argv[arg] << endl;
            exit(1);
         }
      }
   }

   // open the simulation file
   ifstream file(filename.c_str());
   if(!file.is_open())
   {
      cerr << "Could not open file " << filename << endl;
      exit(1);
   }

   // create the simulation
   Simulation simulation(file);

   // do stuff with the simulation here

   // example: print all bursts in every thread in every process
   for(map<int, Process*>::iterator process_it = simulation.processes.begin();
         process_it != simulation.processes.end();
         ++process_it)
   {
      // processing a single process
      Process *process = process_it->second;

      cout << "Process "
           << process->pid
           << " has the following threads:"
           << endl;

      for(vector<Thread*>::iterator thread_it = process->threads.begin();
            thread_it != process->threads.end();
            ++thread_it)
      {
         // processing a single thread
         Thread *thread = (*thread_it);

         cout << "   Thread "
              << thread->tid
              << " arrives at "
              << thread->arrival_time
              << " and has the following bursts:"
              << endl;

         for(vector<Burst*>::iterator burst_it = thread->bursts.begin();
               burst_it != thread->bursts.end();
               ++burst_it)
         {
            // processing a single burst

            Burst *burst = (*burst_it);
            char type = '?';

            if(burst->type == CPU)
               type = 'C';
            else if(burst->type == IO)
               type = 'I';

            cout << "      Burst of type "
                 << type
                 << " for length "
                 << burst->length
                 << endl;
         }
      }
   }

   // example: using events and the priority queue
   // the threads specified are NULL in the example, but you should specify
   // your own

   // event 1 indicates that a process arrives at 50
   Event *event1 = new Event(ARRIVAL, NULL, 50);
   // event 2 indicates that a thread is done with I/O at 27; the NULL would
   // specify the thread that was done with its I/O
   Event *event2 = new Event(IO_DONE, NULL, 27);

   // add the events to the simulation
   simulation.events.push(event1);
   simulation.events.push(event2);

   // the first event to come back should be at 27, and the second should be
   // 50
   cout << "The first event to return happens at "
        << simulation.events.top()->time
        << endl;
   // actually remove the event from the queue
   simulation.events.pop();
   // get the next event
   cout << "The second event to return happens at "
        << simulation.events.top()->time
        << endl;
   // actually remove the event from the queue
   simulation.events.pop();

   // close the file
   file.close();
}
