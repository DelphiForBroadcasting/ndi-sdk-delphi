#pragma once

// Are files exported ?
#ifdef	COMPILE_PROCESSING_AIRSEND
#define	PROCESSING_AIRSEND_API	__declspec(dllexport)
#else	// COMPILE_PROCESSING_AIRSEND
#define	PROCESSING_AIRSEND_API	__declspec(dllimport)
#endif	// COMPILE_PROCESSING_AIRSEND

// The following SDK wraps the newer version of this API (AirSend2) such that calls to this API are forwarded
// to both the older API (AirSend1) and the newer one (AirSend2). There are however some differences to note :
//		- Format changes are supported much more robustly using the newer API, even thought this
//		  interface.
//		- AirSend_request_connection has no new equivalent and will work with the older API, but not the newer.
//		- AirSend_get_notification_handle is not wrapped in this SDK. This functionality is provided through
//		  the new API if you need it.
//		- AirSend_pp_get_command is not wrapped on this API. This functionality is provided through
//		  the new API if you need it.

// Create and initialize an AirSend instance. This will return NULL if it fails.
extern "C" PROCESSING_AIRSEND_API
			void* AirSend_Create( // The video resolution. This should be a multiple of 8 pixels wide.
								  // This is the full frame resolution and not the per field resolution
								  // so for instance a 1920x1080 interlaced video stream would store
								  // xres=1920 yres=1080
								  const int xres, 
								  const int yres,
								  // The frame-rate as a numerator and denominator. Examples :
								  // NTSC, 480i30, 1080i30 : 30000/1001
								  // NTSC, 720p60 : 60000/1001
								  // PAL, 576i50, 1080i50 : 30000/1200
								  // PAL, 720p50 : 60000/1200
								  const int frame_rate_n, 
								  const int frame_rate_d,
								  // Is this field interlaced or not ?
								  const bool progressive,
								  // The image aspect ratio as a floating point. For instance
								  // 4:3  = 4.0/3.0  = 1.33333
								  // 16:9 = 16.0/9.0 = 1.77778
								  const float aspect_ratio,
								  // Do we want audio ?
								  const bool audio_enabled,
								  // The number of audio channels. 
								  const int no_channels,
								  // The audio sample-rate
								  const int sample_rate);

// Destroy an instance of AirSend that was created by AirSend_Create.
extern "C" PROCESSING_AIRSEND_API
			void AirSend_Destroy(void* p_instance);

// This allows the video format to be changed on the fly. If false is returned the format change was not successful.
// If the format does not actually change, then this function will return immediately (i.e. its fine to call it
// on every frame if you need to for code simplicity).
extern "C" PROCESSING_AIRSEND_API
			const bool AirSend_change_video_format( 
									// The AirSend instance
									void* p_instance,
									// The video resolution. This should be a multiple of 8 pixels wide.
								    // This is the full frame resolution and not the per field resolution
									// so for instance a 1920x1080 interlaced video stream would store
									// xres=1920 yres=1080
									const int xres, const int yres, 
									// The frame-rate as a numerator and denominator. Examples :
									// NTSC, 480i30, 1080i30 : 30000/1001
									// NTSC, 720p60 : 60000/1001
									// PAL, 576i50, 1080i50 : 30000/1200
									// PAL, 720p50 : 60000/1200
									const int frame_rate_n, const int frame_rate_d, 
									// Is this field interlaced or not ?
									const bool progressive,
									// The image aspect ratio as a floating point. For instance
									// 4:3  = 4.0/3.0  = 1.33333
									// 16:9 = 16.0/9.0 = 1.77778
									const float aspect_ratio );

// Add a video frame. This is in YCbCr format and may have an optional alpha channel.
// This is stored in an uncompressed video buffer of FourCC UYVY which has 16 bits per pixel
// YUV 4:2:2 (Y sample at every pixel, U and V sampled at every second pixel horizontally on each line). 
// This means that the stride of the image is xres*2 bytes pointed to by p_ycbcr. 
// For fielded video, the two fields are interleaved together and it is assumed that field 0 is always
// above field 1 which matches all modern video formats. It is recommended that if you desire to send
// 486 line video that you drop the first line and the bottom 5 lines and send 480 line video. 
// The return value is true when connected, false when not connected.
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_ycbcr( void* p_instance, const BYTE* p_ycbcr );

extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_ycbcr_alpha( void* p_instance, const BYTE* p_ycbcr, const BYTE* p_alpha );

extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_ycbcr_stride( void* p_instance, const BYTE* p_ycbcr, const int ycbcr_stride_in_bytes );

extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_ycbcr_alpha_stride( void* p_instance, const BYTE* p_ycbcr, const int ycbcr_stride_in_bytes, 
																		 const BYTE* p_alpha, const int alpha_stride_in_bytes );

// If your application renders video as a sequence of interleaved fields, entirely independant of each-other then you
// may use these functions to avoid adding them/ These functions are currently not supported in formats other than YCbCr. 
// These functions may be used with progressive video, in which case the field number will be ignored. Currently these
// functions do not accept a stride parameter, it is assumed that the data stride is xres*2 for ycbcr, and xres for alpha.
// The field number is an integer that can be 0 or 1.
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_field_ycbcr( void* p_instance, const int field_no, const BYTE* p_ycbcr );

extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_field_ycbcr_alpha( void* p_instance, const int field_no, const BYTE* p_ycbcr, const BYTE* p_alpha );

// These methods allow you to add video in BGRA and BGRX formats. (BGRX is 32 bit BGR with the alpha channel
// ignored.) Frames are provided as uncompressed buffers. YCbCr is the preferred color space and these are
// provided as a conveniance.
// The return value is true when connected, false when not connected.
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_bgra( void* p_instance, const BYTE* p_bgra );
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_bgrx( void* p_instance, const BYTE* p_bgrx );

extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_bgra_stride( void* p_instance, const BYTE* p_bgra, const int bgra_stride_in_bytes );
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_bgrx_stride( void* p_instance, const BYTE* p_bgrx, const int bgrx_stride_in_bytes );

// Because Windows tends to create images bottom to top by default in memory, there are versions of the
// BGR? functions that will send the video frame vertically flipped to avoid you needing to use CPU time
// and memory bandwidth doing this yourself.
// These functions are provided as a conveniance, since there is nothing they do which cannot also be done
// with the strided versions above.
// The return value is true when connected, false when not connected.
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_bgra_flipped( void* p_instance, const BYTE* p_bgra );
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_frame_bgrx_flipped( void* p_instance, const BYTE* p_bgrx );

// Add audio data. This should be in 16 bit PCM uncompressed and all channels are interleaved together.
// Because audio and video are muxed together and send to the video source it is important that you send
// these at the same rate since video frames will be "held" in the muxer until the corresponding audio
// is received so that all data can be sent in "display" order to the TriCaster.
// The return value is true when connected, false when not connected.
extern "C" PROCESSING_AIRSEND_API
			bool AirSend_add_audio( void* p_instance, const short* p_src, const int no_samples );

// This allows you to tell a particular TriCaster that is on "Receive" mode to watch this video source.
// By default, on a TriCaster "Net 1" is on port 7000, and "Net 2" is on port 7001. Note that a full implementation
// should use Bonjour to locate the TriCaster as described in the SDK documentation; when working this way
// you would always know the true port numbers.
extern "C" PROCESSING_AIRSEND_API
			void AirSend_request_connection( void* p_instance, const ULONG IP, const USHORT Port );

// It is sometimes desirable to provide data in BGRA format and color convert it on the main thread, and then
// use a subsequent thread to submit the frame for processing. For instamce in DirectX (and OpenGL), the lock()
// call can often only performed on the main render thread. It is potentially conveniant to color convert the
// buffer on this thread and then unlock it. These functions are internally highly optimized, they run in CCIR709
// color space; if you require a different color space we leave this as an excercise for the reader.
//
// (Note that the better solution would always be to lock on the render thread, have another thread submit the
//  frame, then place it back on a queue to have the render thread unlock it. To make this work well you would
//  often need a pair of buffers that you ping-pong between.)
//
extern "C" PROCESSING_AIRSEND_API
			void AirSend_util_bgra_ycbcr_alpha_stride( const BYTE* p_src_bgra, const int src_bgra_stride_in_bytes,
														     BYTE* p_dst_ycbcr, const int dst_ycbcr_stride_in_bytes,
															 BYTE* p_dst_alpha, const int dst_alpha_stride_in_bytes,
													   const int xres, const int yres );

extern "C" PROCESSING_AIRSEND_API
			void AirSend_util_bgrx_ycbcr_stride( const BYTE* p_src_bgrx, const int src_bgrx_stride_in_bytes,
													   BYTE* p_dst_ycbcr, const int dst_ycbcr_stride_in_bytes,
													   const int xres, const int yres );

// The following code can be used to receive information about whether this input is currently on output or not.
// This can be used to receive all forms of notification for the up stream device.
//
// This will return you a macro command that has been sent up-stream, to control your system. A macro command 
// consists of a named command, and a set of key-value pairs that represent the parameters for the command.
// The following represents typical code that might be used to process up-stream commands.
//
//	void my_command_thread( void )
//	{	// Get the handle that notifies you of AirSend status changes
//		HANDLE hAirSendEvents = AirSend_get_notification_handle( p_AirSend );
//	
//		// You will need to ensure that you exit this loop when your application is exiting.
//		// Ensure that you do not delete p_AirSend until outside of these commands. In practice
//		// you probably do not want INFINITE here, but rather something that is checking for
//		// your own application to exit as well, maybe with WaitForMultipleObjects
//		while( ::WaitForSingleObject( hAirSendEvents, INFINITE ) == WAIT_OBJECT_0 )
//		{	// Get the Tally states
//			const bool is_on_preview = AirSend_is_on_preview( p_AirSend );
//			const bool is_on_program = AirSend_is_on_program( p_AirSend );
//			const bool is_connected  = AirSend_is_connected( p_AirSend );
//	
//			// If the Tally status did something that you think you should react too (for instance
//			// going from is_on_program=false to is_on_program=true, then handle it here.
//			handle_tally_if_they_changed();
//	
//			// Process any macro commands
//			while( 1 )
//			{	// While there are commands to process
//				const wchar_t** p_cmd_parameters = AirSend_pp_get_command( p_AirSend );
//				if ( !p_cmd_parameters ) break;
//	
//				// Print the command name
//				::wprintf( L"Command = %s, ", p_cmd_parameters[0] );
//	
//				// Print the parameters for the command
//				for( int idx=1; p_cmd_parameters[idx]; idx+=2 )
//					::wprintf( L"%s = \"%s\", ", p_cmd_parameters[idx], p_cmd_parameters[idx+1] );
//				::wprintf( L"\n" );
//			}
//		}
//	}
//	
// This gives you a HANDLE that will be triggered when the up-stream source has it's visibility changed. 
// You can also just poll the functions that give you the data if you desire although you will get slightly
// less accurate timing of course.
extern "C" PROCESSING_AIRSEND_API
			HANDLE AirSend_get_notification_handle( void* p_instance );

// Are we connected ?
extern "C" PROCESSING_AIRSEND_API
			const bool AirSend_is_connected( void* p_instance );

// Are we visible on the program row ?
// Please note : These settings are not supported by all TriCaster versions.
extern "C" PROCESSING_AIRSEND_API
			const bool AirSend_is_on_program( void* p_instance );

// Are we visible on the preview row ?
// Please note : These settings are not supported by all TriCaster versions.
extern "C" PROCESSING_AIRSEND_API
			const bool AirSend_is_on_preview( void* p_instance );

// THis is documented with an example above
// Please note : These settings are not supported by all TriCaster versions.
extern "C" PROCESSING_AIRSEND_API
			const wchar_t** AirSend_pp_get_command( void* p_instance );