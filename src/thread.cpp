#include "thread.h"

Thread::Thread(int arrival_time, Process *process, int tid)
{
   this->arrival_time = arrival_time;
   this->process = process;
   this->tid = tid;
   this->last_io_start = -1;
}
