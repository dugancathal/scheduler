#include "event.h"

Event::Event(EventType event_type, Thread *thread, int time)
{
   this->event_type = event_type;
   this->thread = thread;
   this->time = time;
}
