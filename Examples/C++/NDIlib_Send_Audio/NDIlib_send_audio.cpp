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
	const NDIlib_send_create_t NDI_send_create_desc = { "My Audio", NULL, FALSE, TRUE };

	// We create the NDI finder
	NDIlib_send_instance_t pNDI_send = NDIlib_send_create(&NDI_send_create_desc);
	if (!pNDI_send) return FALSE;

	// Provide a meta-data registration that allows people to know what we are. Note that this is optional.
	// Note that it is possible for senders to also register their preferred video formats.
	static const char* p_connection_string = "<ndi_product long_name=\"NDILib Send Example.\" "
											 "             short_name=\"NDILib Send\" "
											 "             manufacturer=\"CoolCo, inc.\" "
											 "             version=\"1.000.000\" "
											 "             session=\"default\" "
											 "             model_name=\"S1\" "
											 "             serial=\"ABCDEFG\"/>";
	const NDIlib_metadata_frame_t NDI_connection_type = {
		// The length
		(DWORD)::strlen(p_connection_string),
		// Timecode (synthesized for us !)
		NDIlib_send_timecode_synthesize,
		// The string
		(char*)p_connection_string
	};
	NDIlib_send_add_connection_metadata(pNDI_send, &NDI_connection_type);

	// We are going to send 1920 audio samples at a time
	const NDIlib_audio_frame_t NDI_audio_frame = {
		// 48kHz
		48000,
		// The number of audio channels
		4,
		// The number of audio samples per channel
		1920,
		// The timecode of this frame in 10ns intervals
		0LL,
		// The audio data
		(FLOAT*)malloc(1920 * 4 * sizeof(FLOAT)),
		// The audio channel stride
		1920 * sizeof(FLOAT)
	};

	// We will send 1000 frames of video. 
	for (DWORD idx = 0; idx < 1000; idx++)
	{	// Fill in the buffer with silence. It is likely that you would do something much smarter than this.
		for (int ch = 0; ch < 4; ch++)
		{	// Get the pointer to the start of this channel
			FLOAT* p_ch = (FLOAT*)((BYTE*)NDI_audio_frame.p_data + ch*NDI_audio_frame.channel_stride_in_bytes);

			// Fill it with silence
			for (int sample_no = 0; sample_no < 1920; sample_no++)
				p_ch[sample_no] = 0.0f;
		}

		// We now submit the frame. Note that this call will be clocked so that we end up submitting 
		// at exactly 48kHz
		NDIlib_send_send_audio(pNDI_send, &NDI_audio_frame);

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

