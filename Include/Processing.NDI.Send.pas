{$ifndef PROCESSING_NDI_SEND_H}
	{$define PROCESSING_NDI_SEND_H}

//**************************************************************************************************************************
// Structures and type definitions required by NDI sending
// The reference to an instance of the sender
type
  TNDIlib_send_instance = Pointer;

// The creation structure that is used when you are creating a sender
type
  PNDIlib_send_create = ^TNDIlib_send_create;
  TNDIlib_send_create = packed record
  	// The name of the NDI source to create. This is a NULL terminated UTF8 string.
    p_ndi_name : PAnsiChar;

    // What groups should this source be part of
    p_groups : PAnsiChar;

    // Do you want audio and video to "clock" themselves. When they are clocked then
    // by adding video frames, they will be rate limited to match the current frame-rate
    // that you are submitting at. The same is true for audio. In general if you are submitting
    // video and audio off a single thread then you should only clock one of them (video is
    // probably the better of the two to clock off). If you are submtiting audio and video
    // of seperate threads then having both clocked can be useful.
    clock_video : integer;
    clock_audio : integer;
  end;

// Create a new sender instance. This will return NULL if it fails.
function NDIlib_send_create(p_create_settings: PNDIlib_send_create): TNDIlib_send_instance;
  cdecl; external PROCESSINGNDILIB_API;

// This will destroy an existing finder instance.
procedure NDIlib_send_destroy(p_instance: TNDIlib_send_instance);
  cdecl; external PROCESSINGNDILIB_API;

// This will add a video frame
procedure NDIlib_send_send_video(p_instance: TNDIlib_send_instance; p_video_data : PNDIlib_video_frame);
  cdecl; external PROCESSINGNDILIB_API;

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
procedure NDIlib_send_send_video_async(p_instance: TNDIlib_send_instance; p_video_data: PNDIlib_video_frame);
  cdecl; external PROCESSINGNDILIB_API;

// This will add an audio frame
procedure NDIlib_send_send_audio(p_instance: TNDIlib_send_instance; p_audio_data: PNDIlib_audio_frame);
  cdecl; external PROCESSINGNDILIB_API;

// This will add a metadata frame
procedure NDIlib_send_send_metadata(p_instance: TNDIlib_send_instance; p_metadata: PNDIlib_metadata_frame);
  cdecl; external PROCESSINGNDILIB_API;

// This allows you to receive metadata from the other end of the connection
function NDIlib_send_capture(p_instance: TNDIlib_send_instance;		// The instance data
											  p_metadata: PNDIlib_metadata_frame;		// The metadata received (can be NULL)
											  const timeout_in_ms: cardinal): TNDIlib_frame_type_e;				// The amount of time in milliseconds to wait for data.
  cdecl; external PROCESSINGNDILIB_API;

// Free the buffers returned by capture for metadata
procedure NDIlib_send_free_metadata(p_instance: TNDIlib_send_instance; p_metadata: PNDIlib_metadata_frame);
  cdecl; external PROCESSINGNDILIB_API;

// Determine the current tally sate. If you specify a timeout then it will wait until it has changed, otherwise it will simply poll it
// and return the current tally immediately. The return value is whether anything has actually change (TRUE) or whether it timed out (FALSE)

function NDIlib_send_get_tally(p_instance : TNDIlib_send_instance; p_tally: PNDIlib_tally; timeout_in_ms: cardinal): integer;
  cdecl; external PROCESSINGNDILIB_API;

// Get the current number of receivers connected to this source. This can be used to avoid even rendering when nothing is connected to the video source.
// which can significantly improve the efficiency if you want to make a lot of sources available on the network. If you specify a timeout that is not
// 0 then it will wait until there are connections for this amount of time.
function NDIlib_send_get_no_connections(p_instance : TNDIlib_send_instance; const timeout_in_ms: cardinal): cardinal;
  cdecl; external PROCESSINGNDILIB_API;

// Connection based metadata is data that is sent automatically each time a new connection is received. You queue all of these
// up and they are sent on each connection. To reset them you need to clear them all and set them up again.
procedure NDIlib_send_clear_connection_metadata(p_instance : TNDIlib_send_instance);
  cdecl; external PROCESSINGNDILIB_API;

// Add a connection metadata string to the list of what is sent on each new connection. If someone is already connected then
// this string will be sent to them immediately.
procedure NDIlib_send_add_connection_metadata(p_instance : TNDIlib_send_instance; p_metadata: PNDIlib_metadata_frame);
  cdecl; external PROCESSINGNDILIB_API;

{$endif} (* PROCESSING_NDI_SEND_H *)
