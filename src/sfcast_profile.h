#ifndef SFCAST_PROFILE_H
#define SFCAST_PROFILE_H

#include "port.h"

#ifdef SFCAST_PROFILE

void SfcastProfileFrameStart();
void SfcastProfileCpuEnd();
void SfcastProfileFrameEnd(bool8 rendered, uint32 skipped_frames);
void SfcastProfileRenderStart();
void SfcastProfileRenderEnd();
void SfcastProfileDisplayStart();
void SfcastProfileDisplayEnd();
void SfcastProfileSoundStart();
void SfcastProfileSoundEnd();

#else

static inline void SfcastProfileFrameStart() {}
static inline void SfcastProfileCpuEnd() {}
static inline void SfcastProfileFrameEnd(bool8, uint32) {}
static inline void SfcastProfileRenderStart() {}
static inline void SfcastProfileRenderEnd() {}
static inline void SfcastProfileDisplayStart() {}
static inline void SfcastProfileDisplayEnd() {}
static inline void SfcastProfileSoundStart() {}
static inline void SfcastProfileSoundEnd() {}

#endif

#endif
