#include "stdafx.h"
#include <Processing.NDI.Lib.h>

const int clamp(const float x)
{	if (x < 0.0f) return 0;
	if (x > 1.0f) return 255;
	return (int)(x*255.0f);
}

int _tmain(int argc, _TCHAR* argv[])
{	// Not required, but "correct" (see the SDK documentation.
	if (!NDIlib_initialize())
	{	// Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
		// you can check this directly with a call to NDIlib_is_supported_CPU()
		printf("Cannot run NDI.");
		return 0;
	}

	// Create an NDI source that is called "My Video". This is not clocked since 
	// we are going to write a benchmark.
	char NDI_name[128];
	::sprintf(NDI_name, "Benchmark %d", ::GetTickCount());
	const NDIlib_send_create_t NDI_send_create_desc = { NDI_name, NULL, FALSE, FALSE };

	// Display that we're thinking about thins
	printf("Generating content for benchmark ...\n");

	// We create the NDI sender
	NDIlib_send_instance_t pNDI_send = NDIlib_send_create(&NDI_send_create_desc);
	if (!pNDI_send) return FALSE;

	// We build a video frame that is twice to long, which allows us to "scroll" down the image
	// so that the content is changing but it takes no CPU time to generate this.
	const int xres = 3840;
	const int yres = 2160;
	const int framerate_n = 60000;
	const int framerate_d = 1001;
	const int scroll_dist = 4;

	// Allocate the memory
	BYTE* p_src = (BYTE*)malloc(xres*yres*scroll_dist * 2);
	for (int y = 0; y < yres*scroll_dist; y++)
	{	// Get the line
		BYTE* p_src_line = p_src + y*xres * 2;
		for (int x = 0; x < xres; x += 2, p_src_line+=4)
		{	// Generate some patterns of some kind
			const float fy   = (float)y / (float)yres;
			const float fx_0 = (float)(x + 0) / (float)xres;
			const float fx_1 = (float)(x + 1) / (float)xres;

			// Get the color in RGB
			const int r0 = clamp(cos(fx_0* 9.0f + fy* 9.5f)*0.5f + 0.5f);
			const int g0 = clamp(cos(fx_0*12.0f + fy*40.5f)*0.5f + 0.5f);
			const int b0 = clamp(cos(fx_0*23.0f + fy*15.5f)*0.5f + 0.5f);

			const int r1 = clamp(cos(fx_1* 9.0f + fy* 9.5f)*0.5f + 0.5f);
			const int g1 = clamp(cos(fx_1*12.0f + fy*40.5f)*0.5f + 0.5f);
			const int b1 = clamp(cos(fx_1*23.0f + fy*15.5f)*0.5f + 0.5f);

			// Color convert the pixels using integer
			p_src_line[0] = std::max(0, std::min(255, ((112 * b0 - 87 * g0 - 26 * r0) >> 8) + 128));
			p_src_line[1] = std::max(0, std::min(255, ((16 * b0 + 157 * g0 + 47 * r0) >> 8) + 16));
			p_src_line[2] = std::max(0, std::min(255, ((112 * r1 - 10 * b1 - 102 * g1) >> 8) + 128));
			p_src_line[3] = std::max(0, std::min(255, ((16 * b1 + 157 * g1 + 47 * r1) >> 8) + 16));
		}
	}

	// We want high precision timing
	TIMECAPS TimeCaps_;
	::timeGetDevCaps(&TimeCaps_, sizeof(TimeCaps_));
	::timeBeginPeriod(TimeCaps_.wPeriodMin);

	// Keep track of times
	DWORD prev_time = ::timeGetTime();

	// Display that we're thinking about thins
	printf("Running benchmark ...\n");

	// Cycle over data
	for (int idx=0;;idx++)
	{	// We are going to create a 1920x1080 interlaced frame at 29.97Hz.
		const NDIlib_video_frame_t NDI_video_frame = {
			// Resolution
			xres, yres,
			// We will stick with RGB color space. Note however that it is generally better to
			// use YCbCr colors spaces if you can since they get end-to-end better video quality
			// and better performance because there is no color dconversion
			NDIlib_FourCC_type_UYVY,
			// The frame-eate
			framerate_n, framerate_d,
			// The aspect ratio (16:9)
			16.0f / 9.0f,
			// This is not a progressive frame
			TRUE,
			// Timecode (synthesized for us !)
			NDIlib_send_timecode_synthesize,
			// The video memory used for this frame
			p_src + xres * 2 * (idx % (yres*(scroll_dist - 1))),
			// The line to line stride of this image
			xres*2
		};

		// We now submit the frame. 
		NDIlib_send_send_video(pNDI_send, &NDI_video_frame);

		// Every 1000 frames we check how long it has taken
		if (idx && ((idx % 1000) == 0))
		{	// Get the time
			const DWORD this_time = ::timeGetTime();

			// Displayt the frames per second
			printf("%dx%d video encoded at %1.1ffps.\n", xres, yres, 1000000.0f / (this_time - prev_time));

			// Cycle the timers
			prev_time = this_time;
		}
	}

	// Free the video frame
	free((void*)p_src);

	// Destroy the NDI sender
	NDIlib_send_destroy(pNDI_send);

	// Not required, but nice
	NDIlib_destroy();

	// Success
	return 0;
}

