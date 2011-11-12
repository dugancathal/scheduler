#ifndef THREAD_H
#define THREAD_H

#include <vector>

class Burst;
class Process;

class Thread
{
   public:
      // arrival time
      int arrival_time;

      // thread id
      int tid;

      // all bursts that are a part of this thread
      std::vector<Burst*> bursts;

      // the process assocated with this thread
      Process *process;

      // the time at which the last I/O burst started; if no active I/O burst,
      // then this should be set to -1
      int last_io_start;

      // constructor
      Thread(int arrival_time, Process *process, int tid);
};

#endif
