{$ifndef PROCESSING_NDI_RECV_H}
	{$define PROCESSING_NDI_RECV_H}


//**************************************************************************************************************************
// Structures and type definitions required by NDI finding
// The reference to an instance of the receiver
type
  TNDIlib_recv_instance = Pointer;

  TNDIlib_recv_bandwidth = (
	  NDIlib_recv_bandwidth_lowest  = 0,			// Receive video at a lower bandwidth and resolution.
	  NDIlib_recv_bandwidth_highest = 100			// Default
  );

// The creation structure that is used when you are creating a receiver
type
  PNDIlib_recv_create = ^TNDIlib_recv_create;
  TNDIlib_recv_create = record
    // The source that you wish to connect to.
    source_to_connect_to : TNDIlib_source;

    // What color space is your preference ?
    //
    //	prefer_UYVY == TRUE
    //		No Alpha channel   : UYVY
    //		With Alpha channel : BGRA
    //
    //	prefer_UYVY == FALSE
    //		No Alpha channel   : BGRA
    //		With Alpha channel : BGRA
    prefer_UYVY : integer;

    // The bandwidth setting that you wish to use for this video source. Bandwidth
    // controlled by changing both the compression level and the resolution of the source.
    // A good use for low bandwidth is working on WIFI connections.
    bandwidth : TNDIlib_recv_bandwidth;

    // When this flag is FALSE, all video that you receive will be progressive. For sources
    // that provide fielded, this is defielded on the receiving side (because we cannot change
    // what the up-stream source was actually rendering. This is provided as a conveniance to
    // down-stream sources that do not wish to understand fielded video. There is almost no
    // performance impact of using this function.
    allow_video_fields : integer;
  end;


// This allows you determine the current performance levels of the receiving to be able to detect whether frames have been dropped
type
  PNDIlib_recv_performance = ^TNDIlib_recv_performance;
  TNDIlib_recv_performance = record
    // The number of video frames
    m_video_frames : Int64;

    // The number of audio frames
    m_audio_frames : Int64;

    // The number of metadata frames
    m_metadata_frames : Int64;
  end;


// Get the current queue depths
type
  PNDIlib_recv_queue = ^TNDIlib_recv_queue;
  TNDIlib_recv_queue = record
    // The number of video frames
    m_video_frames : integer;

    // The number of audio frames
    m_audio_frames : integer;

    // The number of metadata frames
    m_metadata_frames : integer;
  end;


//**************************************************************************************************************************
// Create a new receiver instance. This will return NULL if it fails.
function NDIlib_recv_create2(p_create_settings: PNDIlib_recv_create): TNDIlib_recv_instance;
  cdecl; external PROCESSINGNDILIB_API;

// This function is depreciated, please use NDIlib_recv_create2 if you can. Using this function will continue to work, and be
// supported for backwards compatability. This version sets bandwidth to highest and allow fields to true.
function NDIlib_recv_create(p_create_settings: PNDIlib_recv_create): TNDIlib_recv_instance;
  cdecl; external PROCESSINGNDILIB_API;

// This will destroy an existing receiver instance.
procedure NDIlib_recv_destroy(p_instance : TNDIlib_recv_instance);
  cdecl; external PROCESSINGNDILIB_API;

// This will allow you to receive video, audio and metadata frames.
// Any of the buffers can be NULL, in which case data of that type
// will not be captured in this call. This call can be called simultaneously
// on seperate threads, so it is entirely possible to receive audio, video, metadata
// all on seperate threads. This function will return NDIlib_frame_type_none if no
// data is received within the specified timeout and NDIlib_frame_type_error if the connection is lost.
// Buffers captured with this must be freed with the appropriate free function below.
function NDIlib_recv_capture(
						 p_instance: TNDIlib_recv_instance;			              // The library instance
						 p_video_data: PNDIlib_video_frame;		                // The video data received (can be NULL)
						 p_audio_data: PNDIlib_audio_frame;		                // The audio data received (can be NULL)
						 p_metadata: PNDIlib_metadata_frame;		              // The metadata received (can be NULL)
						 const timeout_in_ms: cardinal): TNDIlib_frame_type_e;  // The amount of time in milliseconds to wait for data.
  cdecl; external PROCESSINGNDILIB_API;

// Free the buffers returned by capture for video
procedure NDIlib_recv_free_video(p_instance: TNDIlib_recv_instance; p_video_data: PNDIlib_video_frame);
  cdecl; external PROCESSINGNDILIB_API;

// Free the buffers returned by capture for audio
procedure NDIlib_recv_free_audio(p_instance: TNDIlib_recv_instance; p_audio_data: PNDIlib_audio_frame);
  cdecl; external PROCESSINGNDILIB_API;

// Free the buffers returned by capture for metadata
procedure NDIlib_recv_free_metadata(p_instance: TNDIlib_recv_instance; p_metadata: PNDIlib_metadata_frame);
  cdecl; external PROCESSINGNDILIB_API;

// This function will send a meta message to the source that we are connected too. This returns FALSE if we are
// not currently connected to anything.
function NDIlib_recv_send_metadata(p_instance: TNDIlib_recv_instance; p_metadata: PNDIlib_metadata_frame): integer;
  cdecl; external PROCESSINGNDILIB_API;

// Set the up-stream tally notifications. This returns FALSE if we are not currently connected to anything. That
// said, the moment that we do connect to something it will automatically be sent the tally state.
function NDIlib_recv_set_tally(p_instance: TNDIlib_recv_instance; p_tally: PNDIlib_tally): integer;
  cdecl; external PROCESSINGNDILIB_API;

// Get the current performance structures. This can be used to determine if you have been calling NDIlib_recv_capture fast
// enough, or if your processing of data is not keeping up with real-time. The total structure will give you the total frame
// counts received, the dropped structure will tell you how many frames have been dropped. Either of these could be NULL.
procedure NDIlib_recv_get_performance(p_instance: TNDIlib_recv_instance; p_total: PNDIlib_recv_performance; p_dropped: PNDIlib_recv_performance);
  cdecl; external PROCESSINGNDILIB_API;

// This will allow you to determine the current queue depth for all of the frame sources at any time.
procedure NDIlib_recv_get_queue(p_instance: TNDIlib_recv_instance; p_total: PNDIlib_recv_queue);
  cdecl; external PROCESSINGNDILIB_API;

// Connection based metadata is data that is sent automatically each time a new connection is received. You queue all of these
// up and they are sent on each connection. To reset them you need to clear them all and set them up again.
procedure NDIlib_recv_clear_connection_metadata(p_instance: TNDIlib_recv_instance);
  cdecl; external PROCESSINGNDILIB_API;

// Add a connection metadata string to the list of what is sent on each new connection. If someone is already connected then
// this string will be sent to them immediately.
procedure NDIlib_recv_add_connection_metadata(p_instance: TNDIlib_recv_instance; p_metadata: PNDIlib_metadata_frame);
  cdecl; external PROCESSINGNDILIB_API;


{$endif} (* PROCESSING_NDI_RECV_H *)
