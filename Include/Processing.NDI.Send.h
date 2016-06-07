#pragma once

//**************************************************************************************************************************
// Structures and type definitions required by NDI sending
// The reference to an instance of the sender
typedef void* NDIlib_send_instance_t;

// The creation structure that is used when you are creating a sender
struct NDIlib_send_create_t
{	// The name of the NDI source to create. This is a NULL terminated UTF8 string.
	const CHAR* p_ndi_name;

	// What groups should this source be part of
	const CHAR* p_groups;

	// Do you want audio and video to "clock" themselves. When they are clocked then 
	// by adding video frames, they will be rate limited to match the current frame-rate
	// that you are submitting at. The same is true for audio. In general if you are submitting
	// video and audio off a single thread then you should only clock one of them (video is
	// probably the better of the two to clock off). If you are submtiting audio and video
	// of seperate threads then having both clocked can be useful.
	BOOL clock_video, clock_audio;
};

// Create a new sender instance. This will return NULL if it fails.
extern "C" PROCESSINGNDILIB_API
NDIlib_send_instance_t NDIlib_send_create(const NDIlib_send_create_t* p_create_settings);

// This will destroy an existing finder instance.
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_destroy(NDIlib_send_instance_t p_instance);

// This will add a video frame
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_send_video(NDIlib_send_instance_t p_instance, const NDIlib_video_frame_t* p_video_data);

// This will add a video frame and will return immediately, having scheduled the frame to be displayed. 
// All processing and sending of the video will occur asynchronously. The memory accessed by NDIlib_video_frame_t 
// cannot be freed or re-used by the caller until a synchronizing event has occured. In general the API is better
// able to take advantage of asynchronous processing than you might be able to by simple having a seperate thread
// to submit frames. 
//
// This call is particularly beneficial when processing BGRA video since it allows any color conversion, compression
// and network sending to all be done on seperate threads from your main rendering thread. 
//
// Synchronozing events are :
//		- a call to NDIlib_send_send_video
//		- a call to NDIlib_send_send_video_async with another frame to be sent
//		- a call to NDIlib_send_send_video with p_video_data=NULL
//		- a call to NDIlib_send_destroy
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_send_video_async(NDIlib_send_instance_t p_instance, const NDIlib_video_frame_t* p_video_data);

// This will add an audio frame
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_send_audio(NDIlib_send_instance_t p_instance, const NDIlib_audio_frame_t* p_audio_data);

// This will add a metadata frame
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_send_metadata(NDIlib_send_instance_t p_instance, const NDIlib_metadata_frame_t* p_metadata);

// This allows you to receive metadata from the other end of the connection
extern "C" PROCESSINGNDILIB_API
const NDIlib_frame_type_e NDIlib_send_capture(NDIlib_send_instance_t p_instance,		// The instance data
											  NDIlib_metadata_frame_t* p_metadata,		// The metadata received (can be NULL)
											  const DWORD timeout_in_ms);				// The amount of time in milliseconds to wait for data.

// Free the buffers returned by capture for metadata
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_free_metadata(NDIlib_send_instance_t p_instance, const NDIlib_metadata_frame_t* p_metadata);

// Determine the current tally sate. If you specify a timeout then it will wait until it has changed, otherwise it will simply poll it
// and return the current tally immediately. The return value is whether anything has actually change (TRUE) or whether it timed out (FALSE)
extern "C" PROCESSINGNDILIB_API
const BOOL NDIlib_send_get_tally(NDIlib_send_instance_t p_instance, NDIlib_tally_t* p_tally, const DWORD timeout_in_ms);

// Get the current number of receivers connected to this source. This can be used to avoid even rendering when nothing is connected to the video source. 
// which can significantly improve the efficiency if you want to make a lot of sources available on the network. If you specify a timeout that is not
// 0 then it will wait until there are connections for this amount of time.
extern "C" PROCESSINGNDILIB_API
const DWORD NDIlib_send_get_no_connections(NDIlib_send_instance_t p_instance, const DWORD timeout_in_ms);

// Connection based metadata is data that is sent automatically each time a new connection is received. You queue all of these
// up and they are sent on each connection. To reset them you need to clear them all and set them up again. 
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_clear_connection_metadata(NDIlib_send_instance_t p_instance);

// Add a connection metadata string to the list of what is sent on each new connection. If someone is already connected then
// this string will be sent to them immediately.
extern "C" PROCESSINGNDILIB_API
void NDIlib_send_add_connection_metadata(NDIlib_send_instance_t p_instance, const NDIlib_metadata_frame_t* p_metadata);