#ifndef PROCESS_H
#define PROCESS_H

#include <vector>

class Thread;

class Process
{
   public:
      int pid;
      std::vector<Thread*> threads;

      // constructor
      Process(int pid);
};

#endif

