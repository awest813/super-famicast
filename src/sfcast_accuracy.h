#ifndef SFCAST_ACCURACY_H
#define SFCAST_ACCURACY_H

#include "snes9x.h"

#ifdef SFCAST_ACCURACY
void SfcastAccuracyFrameEnd();
#else
static inline void SfcastAccuracyFrameEnd() {}
#endif

#endif
