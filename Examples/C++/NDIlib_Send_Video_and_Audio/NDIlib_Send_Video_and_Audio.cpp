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
	
	// Create an NDI source that is called "My Video" and is clocked to the video.
	const NDIlib_send_create_t NDI_send_create_desc = { "My Video and Audio", NULL, TRUE, FALSE };

	// We create the NDI sender
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
		(CHAR*)p_connection_string
	};
	NDIlib_send_add_connection_metadata(pNDI_send, &NDI_connection_type);

	// We are going to create a 1920x1080 interlaced frame at 29.97Hz.
	const NDIlib_video_frame_t NDI_video_frame = {
		// Resolution
		1920, 1080,
		// Use YCbCr video
		NDIlib_FourCC_type_UYVY,
		// The frame-eate
		30000, 1001,
		// The aspect ratio (16:9)
		16.0f / 9.0f,
		// This is not a progressive frame
		TRUE,
		// Timecode (synthesized for us !)
		NDIlib_send_timecode_synthesize,
		// The video memory used for this frame
		(BYTE*)malloc(1920 * 1080 * 2),
		// The line to line stride of this image
		1920 * 2
	};

	// Because 48kHz audio actually involves 1601.6 samples per frame, we make a basic sequence that we follow.
	static const int audio_no_samples[] = { 1602, 1601, 1602, 1601, 1602 };

	// Create an audio buffer
	NDIlib_audio_frame_t NDI_audio_frame = {
		// 48kHz
		48000,
		// Lets submit stereo although there is nothing limiting us
		2,
		// There can be up to 1602 samples, we'll change this on the fly
		1602,
		// Timecode (synthesized for us !)
		NDIlib_send_timecode_synthesize,
		// The buffer
		(FLOAT*)::malloc(sizeof(FLOAT) * 1602 * 2),
		// The inter channel stride
		sizeof(FLOAT) * 1602
	};

	// We will send 1000 frames of video. 
	for (DWORD idx = 0; idx < 1000; idx++)
	{	// Display black ?
		const bool black = (idx % 50) > 10;

		// Because we are clocking to the video it is better to always submit the audio
		// before, although there is very little in it. I'll leave it as an excercies for the
		// reader to work out why.
		NDI_audio_frame.no_samples = audio_no_samples[idx % 5];

		// When not black, insert noise into the buffer. This is a horrible noise, but its just
		// for illustration.
		// Fill in the buffer with silence. It is likely that you would do something much smarter than this.
		for (int ch = 0; ch < 2; ch++)
		{	// Get the pointer to the start of this channel
			FLOAT* p_ch = (FLOAT*)((BYTE*)NDI_audio_frame.p_data + ch*NDI_audio_frame.channel_stride_in_bytes);

			// Fill it with silence
			for (int sample_no = 0; sample_no < 1602; sample_no++)
				p_ch[sample_no] = ((float)rand() / (float)RAND_MAX - 0.5f)*(black ? 0.0f : 2.0f);
		}

		// Submit the audio buffer
		NDIlib_send_send_audio(pNDI_send, &NDI_audio_frame);

		// Every 50 frames display a few frames of while
		wmemset((wchar_t*)NDI_video_frame.p_data, black ? (128 | (16 << 8)) : (128 | (235 << 8)), 1920 * 1080);

		// We now submit the frame. Note that this call will be clocked so that we end up submitting 
		// at exactly 29.97fps.
		NDIlib_send_send_video(pNDI_send, &NDI_video_frame);

		// Just display something helpful
		printf("Frame number %u send.\n", idx);
	}

	// Free the video frame
	free((void*)NDI_video_frame.p_data);
	free((void*)NDI_audio_frame.p_data);

	// Destroy the NDI sender
	NDIlib_send_destroy(pNDI_send);

	// Not required, but nice
	NDIlib_destroy();

	// Finished
	return 0;
}

