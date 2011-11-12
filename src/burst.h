#ifndef BURST_H
#define BURST_H

#include "bursttype.h"

class Burst
{
   public:
      // type of burst
      BurstType type;
      // length of the burst
      int length;

      Burst(BurstType type, int length);
};

#endif
