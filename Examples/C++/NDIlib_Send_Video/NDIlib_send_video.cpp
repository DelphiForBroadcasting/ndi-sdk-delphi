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
	const NDIlib_send_create_t NDI_send_create_desc = { "My Video", NULL, TRUE, FALSE };

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
		// We will stick with RGB color space. Note however that it is generally better to
		// use YCbCr colors spaces if you can since they get end-to-end better video quality
		// and better performance because there is no color dconversion
		NDIlib_FourCC_type_BGRA,
		// The frame-eate
		30000, 1001,
		// The aspect ratio (16:9)
		16.0f / 9.0f,
		// This is not a progressive frame
		FALSE,
		// Timecode (synthesized for us !)
		NDIlib_send_timecode_synthesize,
		// The video memory used for this frame
		(BYTE*)malloc(1920 * 1080 * 4),
		// The line to line stride of this image
		1920 * 4
	};

	// We will send 1000 frames of video. 
	for (;;)
	{	// Get the current time
		const int start_time = ::GetTickCount();

		// Send 200 frames
		for (int idx = 0; idx < 200; idx++)
		{	// Fill in the buffer. It is likely that you would do something much smarter than this.
			::memset((void*)NDI_video_frame.p_data, (idx & 1) ? 255 : 0, 1920 * 1080 * 4);

			// We now submit the frame. Note that this call will be clocked so that we end up submitting at exactly 29.97fps.
			NDIlib_send_send_video(pNDI_send, &NDI_video_frame);
		}

		// Get the end time
		const int end_time = ::GetTickCount();

		// Just display something helpful
		printf("100 frames sent, average fps=%1.2f\n", 200.0f*1000.0f / (float)(end_time - start_time));
	}

	// Free the video frame
	free((void*)NDI_video_frame.p_data);

	// Destroy the NDI sender
	NDIlib_send_destroy(pNDI_send);

	// Not required, but nice
	NDIlib_destroy();

	// Success
	return 0;
}

