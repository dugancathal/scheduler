#ifndef EVENT_H
#define EVENT_H

#include "eventtype.h"

class Thread;

class Event
{
   public:
      // the type of event
      EventType event_type;

      // the thread for which the event applies
      Thread *thread;

      // the time at which the event occurs
      int time;

      // constructor
      Event(EventType event_type, Thread *thread, int time);
};

class CompareEvent
{
   public:
      // returns true if e1 should be before e2
      bool operator()(Event *e1, Event *e2)
      {
         return e1->time >= e2->time;
      }
};

#endif
