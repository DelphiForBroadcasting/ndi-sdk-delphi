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
	
	// Create an NDI source that is called "My Video" and is clocked to the audio.
	const NDIlib_send_create_t NDI_send_create_desc = { "My 16bpp Audio", NULL, FALSE, TRUE };

	// We create the NDI finder
	NDIlib_send_instance_t pNDI_send = NDIlib_send_create(&NDI_send_create_desc);
	if (!pNDI_send) return FALSE;

	// We are going to send 1920 audio samples at a time
	const NDIlib_audio_frame_interleaved_16s_t NDI_audio_frame = {
		// 48kHz
		48000,
		// The number of audio channels
		2,
		// The number of audio samples per channel
		1920,
		// The timecode of this frame in 10ns intervals
		0LL,
		// The reference level, in dB
		0,
		// The audio data
		(SHORT*)malloc(1920 * 2 * sizeof(SHORT)),
	};

	// We will send 1000 frames of video. 
	for (DWORD idx = 0; idx < 1000; idx++)
	{	// Fill in the buffer with silence. It is likely that you would do something much smarter than this.
		::memset(NDI_audio_frame.p_data, 0, NDI_audio_frame.no_samples*NDI_audio_frame.no_channels*sizeof(SHORT));

		// We now submit the frame. Note that this call will be clocked so that we end up submitting 
		// at exactly 48kHz
		NDIlib_util_send_send_audio_interleaved_16s(pNDI_send, &NDI_audio_frame);

		// Just display something helpful
		printf("Frame number %u sent.\n", idx);
	}

	// Free the video frame
	free((void*)NDI_audio_frame.p_data);

	// Destroy the NDI finder
	NDIlib_send_destroy(pNDI_send);

	// Not required, but nice
	NDIlib_destroy();

	// Success
	return 0;
}

