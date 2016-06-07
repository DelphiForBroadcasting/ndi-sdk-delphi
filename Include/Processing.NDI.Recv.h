#pragma once

//**************************************************************************************************************************
// Structures and type definitions required by NDI finding
// The reference to an instance of the receiver
typedef void* NDIlib_recv_instance_t;

enum NDIlib_recv_bandwidth_e : DWORD
{	NDIlib_recv_bandwidth_lowest  = 0,			// Receive video at a lower bandwidth and resolution.
	NDIlib_recv_bandwidth_highest = 100			// Default
};

// The creation structure that is used when you are creating a receiver
struct NDIlib_recv_create_t
{	// The source that you wish to connect to.
	NDIlib_source_t source_to_connect_to;

	// What color space is your preference ?
	//
	//	prefer_UYVY == TRUE
	//		No Alpha channel   : UYVY
	//		With Alpha channel : BGRA
	//
	//	prefer_UYVY == FALSE 
	//		No Alpha channel   : BGRA
	//		With Alpha channel : BGRA
	BOOL prefer_UYVY;

	// The bandwidth setting that you wish to use for this video source. Bandwidth
	// controlled by changing both the compression level and the resolution of the source.
	// A good use for low bandwidth is working on WIFI connections. 
	NDIlib_recv_bandwidth_e bandwidth;

	// When this flag is FALSE, all video that you receive will be progressive. For sources
	// that provide fielded, this is defielded on the receiving side (because we cannot change
	// what the up-stream source was actually rendering. This is provided as a conveniance to
	// down-stream sources that do not wish to understand fielded video. There is almost no 
	// performance impact of using this function.
	BOOL allow_video_fields;
};

// This allows you determine the current performance levels of the receiving to be able to detect whether frames have been dropped
struct NDIlib_recv_performance_t
{	// The number of video frames
	LONGLONG m_video_frames;

	// The number of audio frames
	LONGLONG m_audio_frames;

	// The number of metadata frames
	LONGLONG m_metadata_frames;
};

// Get the current queue depths
struct NDIlib_recv_queue_t
{	// The number of video frames
	int m_video_frames;

	// The number of audio frames
	int m_audio_frames;

	// The number of metadata frames
	int m_metadata_frames;
};

//**************************************************************************************************************************
// Create a new receiver instance. This will return NULL if it fails.
extern "C" PROCESSINGNDILIB_API
NDIlib_recv_instance_t NDIlib_recv_create2(const NDIlib_recv_create_t* p_create_settings);

// This function is depreciated, please use NDIlib_recv_create2 if you can. Using this function will continue to work, and be
// supported for backwards compatability. This version sets bandwidth to highest and allow fields to true.
extern "C" PROCESSINGNDILIB_API
NDIlib_recv_instance_t NDIlib_recv_create(const NDIlib_recv_create_t* p_create_settings);

// This will destroy an existing receiver instance.
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_destroy(NDIlib_recv_instance_t p_instance);

// This will allow you to receive video, audio and metadata frames.
// Any of the buffers can be NULL, in which case data of that type
// will not be captured in this call. This call can be called simultaneously
// on seperate threads, so it is entirely possible to receive audio, video, metadata
// all on seperate threads. This function will return NDIlib_frame_type_none if no
// data is received within the specified timeout and NDIlib_frame_type_error if the connection is lost.
// Buffers captured with this must be freed with the appropriate free function below.
extern "C" PROCESSINGNDILIB_API
const NDIlib_frame_type_e NDIlib_recv_capture(
						 NDIlib_recv_instance_t p_instance,			// The library instance
						 NDIlib_video_frame_t* p_video_data,		// The video data received (can be NULL)
						 NDIlib_audio_frame_t* p_audio_data,		// The audio data received (can be NULL)
						 NDIlib_metadata_frame_t* p_metadata,		// The metadata received (can be NULL)
						 const DWORD timeout_in_ms );				// The amount of time in milliseconds to wait for data.

// Free the buffers returned by capture for video
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_free_video(NDIlib_recv_instance_t p_instance, const NDIlib_video_frame_t* p_video_data);

// Free the buffers returned by capture for audio
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_free_audio(NDIlib_recv_instance_t p_instance, const NDIlib_audio_frame_t* p_audio_data);

// Free the buffers returned by capture for metadata
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_free_metadata(NDIlib_recv_instance_t p_instance, const NDIlib_metadata_frame_t* p_metadata);

// This function will send a meta message to the source that we are connected too. This returns FALSE if we are
// not currently connected to anything.
extern "C" PROCESSINGNDILIB_API
const BOOL NDIlib_recv_send_metadata(NDIlib_recv_instance_t p_instance, const NDIlib_metadata_frame_t* p_metadata);

// Set the up-stream tally notifications. This returns FALSE if we are not currently connected to anything. That
// said, the moment that we do connect to something it will automatically be sent the tally state.
extern "C" PROCESSINGNDILIB_API
const BOOL NDIlib_recv_set_tally(NDIlib_recv_instance_t p_instance, const NDIlib_tally_t* p_tally);

// Get the current performance structures. This can be used to determine if you have been calling NDIlib_recv_capture fast
// enough, or if your processing of data is not keeping up with real-time. The total structure will give you the total frame
// counts received, the dropped structure will tell you how many frames have been dropped. Either of these could be NULL.
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_get_performance(NDIlib_recv_instance_t p_instance, NDIlib_recv_performance_t* p_total, NDIlib_recv_performance_t* p_dropped);

// This will allow you to determine the current queue depth for all of the frame sources at any time. 
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_get_queue(NDIlib_recv_instance_t p_instance, NDIlib_recv_queue_t* p_total);

// Connection based metadata is data that is sent automatically each time a new connection is received. You queue all of these
// up and they are sent on each connection. To reset them you need to clear them all and set them up again. 
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_clear_connection_metadata(NDIlib_recv_instance_t p_instance);

// Add a connection metadata string to the list of what is sent on each new connection. If someone is already connected then
// this string will be sent to them immediately.
extern "C" PROCESSINGNDILIB_API
void NDIlib_recv_add_connection_metadata(NDIlib_recv_instance_t p_instance, const NDIlib_metadata_frame_t* p_metadata);