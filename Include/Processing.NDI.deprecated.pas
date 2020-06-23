{$ifndef PROCESSING_NDI_DEPRECATED_H}
	{$define PROCESSING_NDI_DEPRECATED_H}
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

// This describes a video frame
type
	pNDIlib_video_frame = ^TNDIlib_video_frame;
	TNDIlib_video_frame = record
		// The resolution of this frame
		xres, yres  : Cardinal;

		// What FourCC this is with. This can be two values
		FourCC : TNDIlib_FourCC_type;

		// What is the frame-rate of this frame.
		// For instance NTSC is 30000,1001 = 30000/1001 = 29.97fps
		frame_rate_N, frame_rate_D  : Integer;

		// What is the picture aspect ratio of this frame.
		// For instance 16.0/9.0 = 1.778 is 16:9 video
		picture_aspect_ratio  : Single;

		// Is this a fielded frame, or is it progressive
		is_progressive  : integer;

		// The timecode of this frame in 100ns intervals
		timecode  : Int64;

		// The video data itself
		p_data  : PByte;

		// The inter line stride of the video data, in bytes.
		line_stride_in_bytes: Integer;
	end;

// This describes an audio frame
type
	pNDIlib_audio_frame = ^TNDIlib_audio_frame;
	TNDIlib_audio_frame = record
		// The sample-rate of this buffer
		sample_rate: Integer;

		// The number of audio channels
		no_channels: Integer;

		// The number of audio samples per channel
		no_samples: Integer;

		// The timecode of this frame in 100ns intervals
		timecode: int64;

		// The audio data
		p_data: PSingle;

		// The inter channel stride of the audio channels, in bytes
		channel_stride_in_bytes: Integer;
	end;

// For legacy reasons I called this the wrong thing. For backwards compatibility.
function NDIlib_find_create2(p_create_settings: pNDIlib_find_create = nil): pNDIlib_find_instance;
	cdecl; external PROCESSINGNDILIB_API; deprecated;
  
function NDIlib_find_create(p_create_settings: pNDIlib_find_create = nil): pNDIlib_find_instance;
	cdecl; external PROCESSINGNDILIB_API; deprecated;


// DEPRECATED. This function is basically exactly the following and was confusing to use.
//    if ((!timeout_in_ms) || (NDIlib_find_wait_for_sources(timeout_in_ms))) 
//        return NDIlib_find_get_current_sources(p_instance, p_no_sources);
//    return NULL;
function NDIlib_find_get_sources(p_instance: pNDIlib_find_instance; var p_no_sources: Cardinal; const timeout_in_ms: Cardinal): pNDIlib_source;
	cdecl; external PROCESSINGNDILIB_API; deprecated;
  
// The creation structure that is used when you are creating a receiver
type
	pNDIlib_recv_create = ^TNDIlib_recv_create;
	TNDIlib_recv_create = record
		// The source that you wish to connect to.
		source_to_connect_to : TNDIlib_source;

		// Your preference of color space. See above.
		color_format : TNDIlib_recv_color_format;

		// The bandwidth setting that you wish to use for this video source. Bandwidth
		// controlled by changing both the compression level and the resolution of the source.
		// A good use for low bandwidth is working on WIFI connections.
		bandwidth : TNDIlib_recv_bandwidth;

		// When this flag is FALSE, all video that you receive will be progressive. For sources
		// that provide fields, this is de-interlaced on the receiving side (because we cannot change
		// what the up-stream source was actually rendering. This is provided as a convenience to
		// down-stream sources that do not wish to understand fielded video. There is almost no 
		// performance impact of using this function.
		allow_video_fields : LongBool;
	end;
	
// This function is deprecated, please use NDIlib_recv_create_v3 if you can. Using this function will continue to work, and be
// supported for backwards compatibility. If the input parameter is NULL it will be created with default settings and an automatically
// determined receiver name,
function NDIlib_recv_create_v2(p_create_settings: pNDIlib_recv_create): pNDIlib_recv_instance;
	cdecl; external PROCESSINGNDILIB_API; deprecated;

// For legacy reasons I called this the wrong thing. For backwards compatibility. If the input parameter is NULL it will be created with 
// default settings and an automatically determined receiver name.
function NDIlib_recv_create2(p_create_settings: pNDIlib_recv_create): pNDIlib_recv_instance;
	cdecl; external PROCESSINGNDILIB_API; deprecated;

// This function is deprecated, please use NDIlib_recv_create_v3 if you can. Using this function will continue to work, and be
// supported for backwards compatibility. This version sets bandwidth to highest and allow fields to true. If the input parameter is NULL it 
// will be created with default settings and an automatically determined receiver name.
function NDIlib_recv_create(p_create_settings: pNDIlib_recv_create): pNDIlib_recv_instance;
	cdecl; external PROCESSINGNDILIB_API; deprecated;

// This will allow you to receive video, audio and metadata frames.
// Any of the buffers can be NULL, in which case data of that type
// will not be captured in this call. This call can be called simultaneously
// on separate threads, so it is entirely possible to receive audio, video, metadata
// all on separate threads. This function will return NDIlib_frame_type_none if no
// data is received within the specified timeout and NDIlib_frame_type_error if the connection is lost.
// Buffers captured with this must be freed with the appropriate free function below.
function NDIlib_recv_capture(
						 p_instance: pNDIlib_recv_instance;			              // The library instance
						 p_video_data: pNDIlib_video_frame;		                // The video data received (can be NULL)
						 p_audio_data: pNDIlib_audio_frame;		                // The audio data received (can be NULL)
						 p_metadata: pNDIlib_metadata_frame;		              // The metadata received (can be NULL)
						 const timeout_in_ms: cardinal): TNDIlib_frame_type;  // The amount of time in milliseconds to wait for data.
	cdecl; external PROCESSINGNDILIB_API; deprecated;
	
// Free the buffers returned by capture for video
procedure NDIlib_recv_free_video(p_instance: pNDIlib_recv_instance; p_video_data: pNDIlib_video_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;

// Free the buffers returned by capture for audio
procedure NDIlib_recv_free_audio(p_instance: pNDIlib_recv_instance; p_audio_data: pNDIlib_audio_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;
	
// This will add a video frame
procedure NDIlib_send_send_video(p_instance: pNDIlib_recv_instance; p_video_data : pNDIlib_video_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;

// This will add a video frame and will return immediately, having scheduled the frame to be displayed. 
// All processing and sending of the video will occur asynchronously. The memory accessed by NDIlib_video_frame_t 
// cannot be freed or re-used by the caller until a synchronizing event has occurred. In general the API is better
// able to take advantage of asynchronous processing than you might be able to by simple having a separate thread
// to submit frames. 
//
// This call is particularly beneficial when processing BGRA video since it allows any color conversion, compression
// and network sending to all be done on separate threads from your main rendering thread. 
//
// Synchronizing events are :
// - a call to NDIlib_send_send_video
// - a call to NDIlib_send_send_video_async with another frame to be sent
// - a call to NDIlib_send_send_video with p_video_data=NULL
// - a call to NDIlib_send_destroy
procedure NDIlib_send_send_video_async(p_instance: pNDIlib_send_instance; p_video_data: pNDIlib_video_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;
  
// This will add an audio frame
procedure NDIlib_send_send_audio(p_instance: pNDIlib_send_instance; p_audio_data: pNDIlib_audio_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;
  
// Convert an planar floating point audio buffer into a interleaved short audio buffer. 
// IMPORTANT : You must allocate the space for the samples in the destination to allow for your own memory management.
procedure NDIlib_util_audio_to_interleaved_16s(p_src: pNDIlib_audio_frame; p_dst: pNDIlib_audio_frame_interleaved_16s);
	cdecl; external PROCESSINGNDILIB_API; deprecated;
  
// Convert an interleaved short audio buffer audio buffer into a planar floating point one. 
// IMPORTANT : You must allocate the space for the samples in the destination to allow for your own memory management.
procedure NDIlib_util_audio_from_interleaved_16s(p_src: pNDIlib_audio_frame_interleaved_16s; p_dst: pNDIlib_audio_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;

// Convert an planar floating point audio buffer into a interleaved floating point audio buffer. 
// IMPORTANT : You must allocate the space for the samples in the destination to allow for your own memory management.

procedure NDIlib_util_audio_to_interleaved_32f(p_src: pNDIlib_audio_frame; p_dst: pNDIlib_audio_frame_interleaved_32f);
	cdecl; external PROCESSINGNDILIB_API; deprecated;
	
// Convert an interleaved floating point audio buffer into a planar floating point one. 
// IMPORTANT : You must allocate the space for the samples in the destination to allow for your own memory management.
procedure NDIlib_util_audio_from_interleaved_32f(p_src: pNDIlib_audio_frame_interleaved_32f; p_dst: pNDIlib_audio_frame);
	cdecl; external PROCESSINGNDILIB_API; deprecated;

{$endif} (* PROCESSING_NDI_DEPRECATED_H *)
