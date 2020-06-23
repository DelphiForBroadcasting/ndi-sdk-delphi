{$ifndef PROCESSING_NDI_SEND_H}
	{$define PROCESSING_NDI_SEND_H}

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

// Structures and type definitions required by NDI sending
// The reference to an instance of the sender
type
	pNDIlib_send_instance = Pointer;

// The creation structure that is used when you are creating a sender
type
	pNDIlib_send_create = ^TNDIlib_send_create;
	TNDIlib_send_create = record
		// The name of the NDI source to create. This is a NULL terminated UTF8 string.
		p_ndi_name: PAnsiChar;

		// What groups should this source be part of. NULL means default.
		p_groups: PAnsiChar;

		// Do you want audio and video to "clock" themselves. When they are clocked then 
		// by adding video frames, they will be rate limited to match the current frame-rate
		// that you are submitting at. The same is true for audio. In general if you are submitting
		// video and audio off a single thread then you should only clock one of them (video is
		// probably the better of the two to clock off). If you are submitting audio and video
		// of separate threads then having both clocked can be useful.
		clock_video, clock_audio: LongBool
	end;

// Create a new sender instance. This will return NULL if it fails. If you specify leave p_create_settings null then 
// the sender will be created with default settings. 
function NDIlib_send_create(p_create_settings: pNDIlib_send_create = nil): pNDIlib_send_instance;
	cdecl; external PROCESSINGNDILIB_API;
	
// This will destroy an existing finder instance.
procedure NDIlib_send_destroy(p_instance: pNDIlib_send_instance);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will add a video frame
procedure NDIlib_send_send_video_v2(p_instance: pNDIlib_send_instance; p_video_data: pNDIlib_video_frame_v2);
	cdecl; external PROCESSINGNDILIB_API;
	
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
procedure NDIlib_send_send_video_async_v2(p_instance: pNDIlib_send_instance; p_video_data: pNDIlib_video_frame_v2);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will add an audio frame
procedure NDIlib_send_send_audio_v2(p_instance: pNDIlib_send_instance; p_audio_data: pNDIlib_audio_frame_v2);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will add an audio frame
procedure NDIlib_send_send_audio_v3(p_instance: pNDIlib_send_instance; p_audio_data: pNDIlib_audio_frame_v3);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will add a metadata frame
procedure NDIlib_send_send_metadata(p_instance: pNDIlib_send_instance; p_metadata: pNDIlib_metadata_frame);
	cdecl; external PROCESSINGNDILIB_API;
	
// This allows you to receive metadata from the other end of the connection
function NDIlib_send_capture(
	p_instance: pNDIlib_send_instance;   // The instance data
	p_metadata: pNDIlib_metadata_frame; // The metadata received (can be NULL)
	timeout_in_ms: Cardinal): TNDIlib_frame_type;             // The amount of time in milliseconds to wait for data.
	cdecl; external PROCESSINGNDILIB_API;
	
// Free the buffers returned by capture for metadata
procedure NDIlib_send_free_metadata(p_instance: pNDIlib_send_instance; p_metadata: pNDIlib_metadata_frame);
	cdecl; external PROCESSINGNDILIB_API;
	
// Determine the current tally sate. If you specify a timeout then it will wait until it has changed, otherwise it will simply poll it
// and return the current tally immediately. The return value is whether anything has actually change (true) or whether it timed out (false)
function NDIlib_send_get_tally(p_instance: pNDIlib_send_instance; p_tally: pNDIlib_tally; timeout_in_ms: Cardinal): LongBool;
	cdecl; external PROCESSINGNDILIB_API;
	
// Get the current number of receivers connected to this source. This can be used to avoid even rendering when nothing is connected to the video source. 
// which can significantly improve the efficiency if you want to make a lot of sources available on the network. If you specify a timeout that is not
// 0 then it will wait until there are connections for this amount of time.
function NDIlib_send_get_no_connections(p_instance: pNDIlib_send_instance; timeout_in_ms: Cardinal): Integer;
	cdecl; external PROCESSINGNDILIB_API;
	
// Connection based metadata is data that is sent automatically each time a new connection is received. You queue all of these
// up and they are sent on each connection. To reset them you need to clear them all and set them up again. 
procedure NDIlib_send_clear_connection_metadata(p_instance: pNDIlib_send_instance);
	cdecl; external PROCESSINGNDILIB_API;
	
// Add a connection metadata string to the list of what is sent on each new connection. If someone is already connected then
// this string will be sent to them immediately.
procedure NDIlib_send_add_connection_metadata(p_instance: pNDIlib_send_instance; p_metadata: pNDIlib_metadata_frame);
	cdecl; external PROCESSINGNDILIB_API;
	
// This will assign a new fail-over source for this video source. What this means is that if this video source was to fail
// any receivers would automatically switch over to use this source, unless this source then came back online. You can specify
// NULL to clear the source.
procedure NDIlib_send_set_failover(p_instance: pNDIlib_send_instance; p_failover_source: pNDIlib_source);
	cdecl; external PROCESSINGNDILIB_API;
	
// Retrieve the source information for the given sender instance.  This pointer is valid until NDIlib_send_destroy is called.
function NDIlib_send_get_source_name(p_instance: pNDIlib_send_instance): pNDIlib_source;
	cdecl; external PROCESSINGNDILIB_API;
	
{$endif} (* PROCESSING_NDI_SEND_H *)
