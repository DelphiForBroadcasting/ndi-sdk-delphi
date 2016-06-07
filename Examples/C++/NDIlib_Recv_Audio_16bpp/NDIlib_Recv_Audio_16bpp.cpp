#include "stdafx.h"
#include <Processing.NDI.Lib.h>

int _tmain(int argc, _TCHAR* argv[])
{	// Not required, but "correct" (see the SDK documentation.
	if (!NDIlib_initialize())
	{	// Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
		// you can check this directly with a call to NDIlib_is_supported_CPU()
		printf("Cannot run NDI.");
		return 0;
	}
	
	// We first need to look for a source on the network
	const NDIlib_find_create_t NDI_find_create_desc = { TRUE, NULL };

	// Create a finder
	NDIlib_find_instance_t pNDI_find = NDIlib_find_create(&NDI_find_create_desc);
	if (!pNDI_find) return 0;

	// We wait until there is at least one source on the network
	DWORD no_sources = 0;
	const NDIlib_source_t* p_sources = NULL;
	while (!no_sources)
		// Wait until the sources on the nwtork have changed
		p_sources = NDIlib_find_get_sources(pNDI_find, &no_sources, 10000);

	// We now have at least one source, so we create a receiver to look at it.
	// We tell it that we prefer YCbCr video since it is more efficient for us. If the source has an alpha channel
	// it will still be provided in BGRA
	NDIlib_recv_create_t NDI_recv_create_desc = { p_sources[0], TRUE, /* Highest quality */NDIlib_recv_bandwidth_highest, /* Allow fielded video */TRUE };

	// Create the receiver
	NDIlib_recv_instance_t pNDI_recv = NDIlib_recv_create2(&NDI_recv_create_desc);
	if (!pNDI_recv) return 0;

	// Destroy the NDI finder. We needed to have access to the pointers to p_sources[0]
	NDIlib_find_destroy(pNDI_find);

	// We are now going to mark this source as being on program output for tally purposes (but not on preview)
	const NDIlib_tally_t tally_state = { TRUE, FALSE };
	NDIlib_recv_set_tally(pNDI_recv, &tally_state);

	// Run for one minute
	for (DWORD start = ::GetTickCount(); ::GetTickCount() - start < 60000;)
	{	// The descriptors
		NDIlib_video_frame_t video_frame;
		NDIlib_audio_frame_t audio_frame;
		NDIlib_metadata_frame_t metadata_frame;

		switch (NDIlib_recv_capture(pNDI_recv, &video_frame, &audio_frame, &metadata_frame, 1000))
		{	
		// No data
		case NDIlib_frame_type_none:
			printf("No data received.\n");
			break;

		// Video data
		case NDIlib_frame_type_video:
			printf("Video data received (%dx%d).\n", video_frame.xres, video_frame.yres);
			NDIlib_recv_free_video(pNDI_recv, &video_frame);
			break;

		// Audio data
		case NDIlib_frame_type_audio:
		{	printf("Audio data received (%d samples).\n", audio_frame.no_samples);

			// Allocate enough space for 16bpp interleaved buffer
			NDIlib_audio_frame_interleaved_16s_t audio_frame_16bpp_interleaved = { 0 };
			audio_frame_16bpp_interleaved.reference_level = 20;	// We are going to have 20dB of headroom
			audio_frame_16bpp_interleaved.p_data = new short[audio_frame.no_samples*audio_frame.no_channels];

			// Convert it
			NDIlib_util_audio_to_interleaved_16s(&audio_frame, &audio_frame_16bpp_interleaved);

			// Free the original buffer
			NDIlib_recv_free_audio(pNDI_recv, &audio_frame);

			// Feel free to do something with the interleaved audio data here

			// Free the interleaved audio data
			delete[] audio_frame_16bpp_interleaved.p_data;

		}	break;

		// Meta data
		case NDIlib_frame_type_metadata:
			printf("Meta data received.\n");
			NDIlib_recv_free_metadata(pNDI_recv, &metadata_frame);
			break;
		}
	}

	// Destroy the receiver
	NDIlib_recv_destroy(pNDI_recv);

	// Not required, but nice
	NDIlib_destroy();

	// Finished
	return 0;
}

