{$ifndef PROCESSING_NDI_RECV_H}
	{$define PROCESSING_NDI_RECV_H}

// NOTE : The following MIT license applies to this file ONLY and not to the SDK as a whole. Please review the SDK documentation 
// for the description of the full license terms, which are also provided in the file "NDI License Agreement.pdf" within the SDK or 
// online at http://new.tk/ndisdk_license/. Your use of any part of this SDK is acknowledgment that you agree to the SDK license 
// terms. The full NDI SDK may be downloaded at http://ndi.tv/
//
//*************************************************************************************************************************************
// 
// Copyright(c) 2014-2020, NewTek, inc.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
// files(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, 
// merge, publish, distribute, sublicense, and / or sell copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//*************************************************************************************************************************************

// Structures and type definitions required by NDI finding
// The reference to an instance of the receiver
type
	pNDIlib_recv_instance = Pointer;
  
	TNDIlib_recv_bandwidth = (
		NDIlib_recv_bandwidth_metadata_only = -10, // Receive metadata.
		NDIlib_recv_bandwidth_audio_only = 10,     // Receive metadata, audio.
		NDIlib_recv_bandwidth_lowest = 0,          // Receive metadata, audio, video at a lower bandwidth and resolution.
		NDIlib_recv_bandwidth_highest = 100,       // Receive metadata, audio, video at full resolution.

		// Ensure this is 32bits in size
		NDIlib_recv_bandwidth_max = $7fffffff
	);

	TNDIlib_recv_color_format = (
		// When there is no alpha channel, this mode delivers BGRX
		// When there is an alpha channel, this mode delivers BGRA
		NDIlib_recv_color_format_BGRX_BGRA = 0,

		// When there is no alpha channel, this mode delivers UYVY
		// When there is an alpha channel, this mode delivers BGRA
		NDIlib_recv_color_format_UYVY_BGRA = 1,

		// When there is no alpha channel, this mode delivers BGRX
		// When there is an alpha channel, this mode delivers RGBA
		NDIlib_recv_color_format_RGBX_RGBA = 2,

		// When there is no alpha channel, this mode delivers UYVY
		// When there is an alpha channel, this mode delivers RGBA
		NDIlib_recv_color_format_UYVY_RGBA = 3,

		// This format will try to decode the video using the fastest available color format for the incoming
		// video signal. This format follows the following guidelines, although different platforms might 
		// vary slightly based on their capabilities and specific performance profiles. In general if you want
		// the best performance this mode should be used.
		// 
		// When using this format, you should consider than allow_video_fields is true, and individual fields
		// will always be delivered.
		//
		// For most video sources on most platforms, this will follow the following conventions
		//      No alpha channel : UYVY
		//      Alpha channel    : UYVA
		NDIlib_recv_color_format_fastest = 100,

		// This format will try to provide the video in the format that is the closest to native for the incoming
		// codec yielding the highest quality. Specifically, this allows for receiving on 16bpp color from many
		// sources. 
		// 
		// When using this format, you should consider than allow_video_fields is true, and individual fields
		// will always be delivered. 
		//
		// For most video sources on most platforms, this will follow the following conventions
		//      No alpha channel : P216, or UYVY
		//      Alpha channel    : PA16 or UYVA
		NDIlib_recv_color_format_best = 101,

		// Legacy definitions for backwards compatibility
		NDIlib_recv_color_format_e_BGRX_BGRA = NDIlib_recv_color_format_BGRX_BGRA,
		NDIlib_recv_color_format_e_UYVY_BGRA = NDIlib_recv_color_format_UYVY_BGRA,
		NDIlib_recv_color_format_e_RGBX_RGBA = NDIlib_recv_color_format_RGBX_RGBA,
		NDIlib_recv_color_format_e_UYVY_RGBA = NDIlib_recv_color_format_UYVY_RGBA,

		{$IFDEF WIN32}
		// For Windows we can support flipped images which is unfortunately something that Microsoft decided to do
		// back in the old days. 
		NDIlib_recv_color_format_BGRX_BGRA_flipped = 1000 + NDIlib_recv_color_format_BGRX_BGRA,
		{$ENDIF}

		// Force the size to be 32bits
		NDIlib_recv_color_format_max = $7fffffff
	);
	
// The creation structure that is used when you are creating a receiver
type
	pNDIlib_recv_create_v3 = ^TNDIlib_recv_create_v3;
	TNDIlib_recv_create_v3 = record
		// The source that you wish to connect to.
    source_to_connect_to: TNDIlib_source;

		// Your preference of color space. See above.
		color_format: TNDIlib_recv_color_format;

		// The bandwidth setting that you wish to use for this video source. Bandwidth
		// controlled by changing both the compression level and the resolution of the source.
		// A good use for low bandwidth is working on WIFI connections. 
		bandwidth: TNDIlib_recv_bandwidth;

		// When this flag is FALSE, all video that you receive will be progressive. For sources
		// that provide fields, this is de-interlaced on the receiving side (because we cannot change
		// what the up-stream source was actually rendering. This is provided as a convenience to
		// down-stream sources that do not wish to understand fielded video. There is almost no 
		// performance impact of using this function.
		allow_video_fields: LongBool;

		// The name of the NDI receiver to create. This is a NULL terminated UTF8 string and should be 
		// the name of receive channel that you have. This is in many ways symmetric with the name of
		// senders, so this might be "Channel 1" on your system. If this is NULL then it will use the 
		// filename of your application indexed with the number of the instance number of this receiver.
		p_ndi_recv_name: PAnsiChar;


	end;

// This allows you determine the current performance levels of the receiving to be able to detect whether frames have been dropped
type  
	pNDIlib_recv_performance = ^TNDIlib_recv_performance;
	TNDIlib_recv_performance = record
		// The number of video frames
		video_frames: Int64;

		// The number of audio frames
		audio_frames: Int64;

		// The number of metadata frames
		metadata_frames: Int64;
	end;

// Get the current queue depths
type  
	pNDIlib_recv_queue = ^TNDIlib_recv_queue;
	TNDIlib_recv_queue = record
		video_frames: Integer;

		// The number of audio frames
		audio_frames: Integer;

		// The number of metadata frames
		metadata_frames: Integer;
	end;

//**************************************************************************************************************************
// Create a new receiver instance. This will return NULL if it fails. If you create this with the default settings (NULL)
// then it will automatically determine a receiver name.
function NDIlib_recv_create_v3(p_create_settings: pNDIlib_recv_create_v3 = nil): pNDIlib_recv_instance;
	cdecl; external PROCESSINGNDILIB_API;
	
// This will destroy an existing receiver instance.
procedure NDIlib_recv_destroy(p_instance: pNDIlib_recv_instance);
	cdecl; external PROCESSINGNDILIB_API;
	
// This function allows you to change the connection to another video source, you can also disconnect it by specifying a NULL here. 
// This allows you to preserve a receiver without needing to 
procedure NDIlib_recv_connect(p_instance: pNDIlib_recv_instance; p_src: pNDIlib_source = nil);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will allow you to receive video, audio and metadata frames.
// Any of the buffers can be NULL, in which case data of that type
// will not be captured in this call. This call can be called simultaneously
// on separate threads, so it is entirely possible to receive audio, video, metadata
// all on separate threads. This function will return NDIlib_frame_type_none if no
// data is received within the specified timeout and NDIlib_frame_type_error if the connection is lost.
// Buffers captured with this must be freed with the appropriate free function below.
function NDIlib_recv_capture_v2(
	p_instance: pNDIlib_recv_instance;      			// The library instance
	p_video_data: pNDIlib_video_frame_v2; 				// The video data received (can be NULL)
	p_audio_data: pNDIlib_audio_frame_v2;  				// The audio data received (can be NULL)
	p_metadata: pNDIlib_metadata_frame;    				// The metadata received (can be NULL)
	timeout_in_ms: Cardinal): TNDIlib_frame_type;		// The amount of time in milliseconds to wait for data.
	cdecl; external PROCESSINGNDILIB_API;
	
// This will allow you to receive video, audio and metadata frames.
// Any of the buffers can be NULL, in which case data of that type
// will not be captured in this call. This call can be called simultaneously
// on separate threads, so it is entirely possible to receive audio, video, metadata
// all on separate threads. This function will return NDIlib_frame_type_none if no
// data is received within the specified timeout and NDIlib_frame_type_error if the connection is lost.
// Buffers captured with this must be freed with the appropriate free function below.
function NDIlib_recv_capture_v3(
	p_instance: pNDIlib_recv_instance;      			// The library instance
	p_video_data: pNDIlib_video_frame_v2;  				// The video data received (can be NULL)
	p_audio_data: pNDIlib_audio_frame_v3;  				// The audio data received (can be NULL)
	p_metadata: pNDIlib_metadata_frame;    				// The metadata received (can be NULL)
	timeout_in_ms: Cardinal): TNDIlib_frame_type;		// The amount of time in milliseconds to wait for data.
	cdecl; external PROCESSINGNDILIB_API;
	
// Free the buffers returned by capture for video
procedure NDIlib_recv_free_video_v2(p_instance: pNDIlib_recv_instance; p_video_data: pNDIlib_video_frame_v2);
	cdecl; external PROCESSINGNDILIB_API;
	
// Free the buffers returned by capture for audio
procedure NDIlib_recv_free_audio_v2(p_instance: pNDIlib_recv_instance; p_audio_data: pNDIlib_audio_frame_v2);
	cdecl; external PROCESSINGNDILIB_API;
	
// Free the buffers returned by capture for audio
procedure NDIlib_recv_free_audio_v3(p_instance: pNDIlib_recv_instance; p_audio_data: pNDIlib_audio_frame_v3);
	cdecl; external PROCESSINGNDILIB_API;
	
// Free the buffers returned by capture for metadata
procedure NDIlib_recv_free_metadata(p_instance: pNDIlib_recv_instance; p_metadata: pNDIlib_metadata_frame);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will free a string that was allocated and returned by NDIlib_recv (for instance the NDIlib_recv_get_web_control) function.
procedure NDIlib_recv_free_string(p_instance: pNDIlib_recv_instance; p_string: PAnsiChar);
	cdecl; external PROCESSINGNDILIB_API;
	
// This function will send a meta message to the source that we are connected too. This returns FALSE if we are
// not currently connected to anything.
function NDIlib_recv_send_metadata(p_instance: pNDIlib_recv_instance; p_metadata: pNDIlib_metadata_frame): LongBool;
	cdecl; external PROCESSINGNDILIB_API;
	
// Set the up-stream tally notifications. This returns FALSE if we are not currently connected to anything. That
// said, the moment that we do connect to something it will automatically be sent the tally state.
function NDIlib_recv_set_tally(p_instance: pNDIlib_recv_instance; p_tally: pNDIlib_tally): LongBool;
	cdecl; external PROCESSINGNDILIB_API;
	
// Get the current performance structures. This can be used to determine if you have been calling NDIlib_recv_capture fast
// enough, or if your processing of data is not keeping up with real-time. The total structure will give you the total frame
// counts received, the dropped structure will tell you how many frames have been dropped. Either of these could be NULL.
procedure NDIlib_recv_get_performance(p_instance: pNDIlib_recv_instance; p_total: pNDIlib_recv_performance; p_dropped: pNDIlib_recv_performance);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will allow you to determine the current queue depth for all of the frame sources at any time. 
procedure NDIlib_recv_get_queue(p_instance: pNDIlib_recv_instance; p_total: pNDIlib_recv_queue);
	cdecl; external PROCESSINGNDILIB_API;
	
// Connection based metadata is data that is sent automatically each time a new connection is received. You queue all of these
// up and they are sent on each connection. To reset them you need to clear them all and set them up again. 
procedure NDIlib_recv_clear_connection_metadata(p_instance: pNDIlib_recv_instance);
	cdecl; external PROCESSINGNDILIB_API;
	
// Add a connection metadata string to the list of what is sent on each new connection. If someone is already connected then
// this string will be sent to them immediately.
procedure NDIlib_recv_add_connection_metadata(p_instance: pNDIlib_recv_instance; p_metadata: pNDIlib_metadata_frame);
	cdecl; external PROCESSINGNDILIB_API;
	
// Is this receiver currently connected to a source on the other end, or has the source not yet been found or is no longer online.
// This will normally return 0 or 1
function NDIlib_recv_get_no_connections(p_instance: pNDIlib_recv_instance): Integer;
	cdecl; external PROCESSINGNDILIB_API;
  
// Get the URL that might be used for configuration of this input. Note that it might take a second or two after the connection for 
// this value to be set. This function will return NULL if there is no web control user interface. You should call NDIlib_recv_free_string
// to free the string that is returned by this function. The returned value will be a fully formed URL, for instance "http://10.28.1.192/configuration/"
// To avoid the need to poll this function, you can know when the value of this function might have changed when the 
// NDILib_recv_capture* call would return NDIlib_frame_type_status_change
function NDIlib_recv_get_web_control(p_instance: pNDIlib_recv_instance): PAnsiChar;	
	cdecl; external PROCESSINGNDILIB_API;	

{$endif} (* PROCESSING_NDI_RECV_H *)
