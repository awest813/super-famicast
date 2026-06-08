#include "sfcast_profile.h"

#ifdef SFCAST_PROFILE

#include <stddef.h>
#include <stdio.h>
#include <sys/time.h>

static unsigned long long profile_frame_start_us;
static unsigned long long profile_cpu_start_us;
static unsigned long long profile_render_start_us;
static unsigned long long profile_display_start_us;
static unsigned long long profile_window_start_us;

static unsigned long long profile_cpu_total_us;
static unsigned long long profile_render_total_us;
static unsigned long long profile_display_total_us;
static uint32 profile_frames;
static uint32 profile_rendered_frames;
static uint32 profile_skipped_frames;

static unsigned long long SfcastProfileNowUs()
{
	struct timeval now;
	while (gettimeofday(&now, NULL) < 0) {}
	return ((unsigned long long) now.tv_sec * 1000000ULL) + (unsigned long long) now.tv_usec;
}

void SfcastProfileFrameStart()
{
	profile_frame_start_us = SfcastProfileNowUs();
	profile_cpu_start_us = profile_frame_start_us;
	if (!profile_window_start_us)
		profile_window_start_us = profile_frame_start_us;
}

void SfcastProfileCpuEnd()
{
	unsigned long long now = SfcastProfileNowUs();
	if (profile_cpu_start_us)
		profile_cpu_total_us += now - profile_cpu_start_us;
}

void SfcastProfileFrameEnd(bool8 rendered, uint32 skipped_frames)
{
	unsigned long long now = SfcastProfileNowUs();
	unsigned long long window_us;

	profile_frames++;
	if (rendered)
		profile_rendered_frames++;
	profile_skipped_frames += skipped_frames;

	window_us = now - profile_window_start_us;
	if (window_us >= 1000000ULL)
	{
		uint32 avg_cpu = profile_frames ? (uint32) (profile_cpu_total_us / profile_frames) : 0;
		uint32 avg_render = profile_rendered_frames ? (uint32) (profile_render_total_us / profile_rendered_frames) : 0;
		uint32 avg_display = profile_rendered_frames ? (uint32) (profile_display_total_us / profile_rendered_frames) : 0;

		printf("SFCAST_PROFILE frames=%lu rendered=%lu skipped=%lu cpu_us=%lu render_us=%lu display_us=%lu\n",
			(unsigned long) profile_frames,
			(unsigned long) profile_rendered_frames,
			(unsigned long) profile_skipped_frames,
			(unsigned long) avg_cpu,
			(unsigned long) avg_render,
			(unsigned long) avg_display);

		profile_window_start_us = now;
		profile_cpu_total_us = 0;
		profile_render_total_us = 0;
		profile_display_total_us = 0;
		profile_frames = 0;
		profile_rendered_frames = 0;
		profile_skipped_frames = 0;
	}
}

void SfcastProfileRenderStart()
{
	profile_render_start_us = SfcastProfileNowUs();
}

void SfcastProfileRenderEnd()
{
	unsigned long long now = SfcastProfileNowUs();
	if (profile_render_start_us)
		profile_render_total_us += now - profile_render_start_us;
	profile_render_start_us = 0;
}

void SfcastProfileDisplayStart()
{
	profile_display_start_us = SfcastProfileNowUs();
}

void SfcastProfileDisplayEnd()
{
	unsigned long long now = SfcastProfileNowUs();
	if (profile_display_start_us)
		profile_display_total_us += now - profile_display_start_us;
	profile_display_start_us = 0;
}

#endif
