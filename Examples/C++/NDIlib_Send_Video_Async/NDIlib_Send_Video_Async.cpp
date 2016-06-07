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
	static const char* p_connection_string = "<ndi_product long_name=\"NDILib Send Async Example.\" "
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
	NDIlib_video_frame_t NDI_video_frame = {
		1920, 1080,							// Resolution.
		NDIlib_FourCC_type_BGRA,			// Color space.
		30000, 1001,						// Frame-rate.
		16.0f / 9.0f,						// Aspect ratio.
		TRUE,								// Progressive video.
		NDIlib_send_timecode_synthesize,	// Let the API fill in the timecodes for us.
		NULL,								// This will be filled in below.
		1920 * 4							// The stride of t aline (1920 pixels of BGRA)
	};

	// We are going to need two frame-buffers because one will typically be in flight (being used by NDI send)
	// while we are filling in the other at the same time.
	void* p_frame_buffers[2] = { malloc(1920 * 1080 * 4), malloc(1920 * 1080 * 4) };

	// We will send 1000 frames of video. 
	for (DWORD idx = 0; idx < 1000; idx++)
	{	// Fill in the buffer. Note that we alternate between buffers because we are going to have one buffer processing
		// being filled in while the second is "in flight" and being processed by the API.
		::memset(p_frame_buffers[idx & 1], (idx & 1) ? 255 : 0, 1920 * 1080 * 4);

		// We now submit the frame asynchronously. This means that this call will return immediately and the 
		// API will "own" the memory location until there is a synchronozing event. A synchronouzing event is 
		// one of : NDIlib_send_send_video_async, NDIlib_send_send_video, NDIlib_send_destroy
		NDI_video_frame.p_data = (BYTE*)p_frame_buffers[idx & 1];
		::NDIlib_send_send_video_async(pNDI_send, &NDI_video_frame);
	}

	// Because one buffer is in flight we need to make sure that there is no chance that we might free it before
	// NDI is done with it. You can ensure this either by sending another frame, or just by sending a frame with
	// a NULL pointer.
	::NDIlib_send_send_video_async(pNDI_send, NULL);

	// Free the video frame
	free(p_frame_buffers[0]);
	free(p_frame_buffers[1]);

	// Destroy the NDI sender
	NDIlib_send_destroy(pNDI_send);

	// Not required, but nice
	NDIlib_destroy();

	// Success
	return 0;
}

