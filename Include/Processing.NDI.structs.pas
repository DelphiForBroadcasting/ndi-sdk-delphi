{$ifndef PROCESSING_NDI_STRUCTS_H}
  {$define PROCESSING_NDI_STRUCTS_H}

type
  // An enumeration to specify the type of a packet returned by the functions
	TNDIlib_frame_type = (
		NDIlib_frame_type_none = $00000000,
		NDIlib_frame_type_video = $00000001,
		NDIlib_frame_type_audio = $00000002,
		NDIlib_frame_type_metadata = $00000003,
		NDIlib_frame_type_error = $00000004,

		// This indicates that the settings on this input have changed.
		// For instance, this value will be returned from NDIlib_recv_capture_v2 and NDIlib_recv_capture
		// when the device is known to have new settings, for instance the web URL has changed or the device
		// is now known to be a PTZ camera.
		NDIlib_frame_type_status_change = 100,

		// Ensure that the size is 32bits
		NDIlib_frame_type_max = $7fffffff
	);

	// FourCC values for video frames
	TNDIlib_FourCC_video_type = (
		NDIlib_FourCC_video_type_UYVY = (ord('Y') or (ord('V') shl 8) or (ord('Y') shl 16) or (ord('U') shl 24)),  //YVYU
		NDIlib_FourCC_type_UYVY = NDIlib_FourCC_video_type_UYVY,

		// YCbCr + Alpha color space, using 4:2:2:4.
		// In memory there are two separate planes. The first is a regular
		// UYVY 4:2:2 buffer. Immediately following this in memory is a
		// alpha channel buffer.
		NDIlib_FourCC_video_type_UYVA = (ord('U') or (ord('Y') shl 8) or (ord('V') shl 16) or (ord('A') shl 24)), //NDI_LIB_FOURCC('U', 'Y', 'V', 'A'),
		NDIlib_FourCC_type_UYVA = NDIlib_FourCC_video_type_UYVA,

		// YCbCr color space using 4:2:2 in 16bpp
		// In memory this is a semi-planar format. This is identical to a 16bpp 
		// version of the NV16 format. 
		// The first buffer is a 16bpp luminance buffer. 
		// Immediately after this is an interleaved buffer of 16bpp Cb, Cr pairs.
		NDIlib_FourCC_video_type_P216 = (ord('P') or (ord('2') shl 8) or (ord('1') shl 16) or (ord('6') shl 24)), //NDI_LIB_FOURCC('P', '2', '1', '6'),
		NDIlib_FourCC_type_P216 = NDIlib_FourCC_video_type_P216,

		// YCbCr color space with an alpha channel, using 4:2:2:4
		// In memory this is a semi-planar format.
		// The first buffer is a 16bpp luminance buffer. 
		// Immediately after this is an interleaved buffer of 16bpp Cb, Cr pairs.
		// Immediately after is a single buffer of 16bpp alpha channel.
		NDIlib_FourCC_video_type_PA16 = (ord('P') or (ord('A') shl 8) or (ord('1') shl 16) or (ord('6') shl 24)), //NDI_LIB_FOURCC('P', 'A', '1', '6'),
		NDIlib_FourCC_type_PA16 = NDIlib_FourCC_video_type_PA16,
		
		// Planar 8bit 4:2:0 video format.
		// The first buffer is an 8bpp luminance buffer.
		// Immediately following this is a 8bpp Cr buffer.
		// Immediately following this is a 8bpp Cb buffer.
		NDIlib_FourCC_video_type_YV12 = (ord('Y') or (ord('V') shl 8) or (ord('1') shl 16) or (ord('2') shl 24)), //NDI_LIB_FOURCC('Y', 'V', '1', '2'),
		NDIlib_FourCC_type_YV12 = NDIlib_FourCC_video_type_YV12,

		// The first buffer is an 8bpp luminance buffer.
		// Immediately following this is a 8bpp Cb buffer.
		// Immediately following this is a 8bpp Cr buffer.
		NDIlib_FourCC_video_type_I420 = (ord('I') or (ord('4') shl 8) or (ord('2') shl 16) or (ord('0') shl 24)), //NDI_LIB_FOURCC('I', '4', '2', '0'),
		NDIlib_FourCC_type_I420 = NDIlib_FourCC_video_type_I420,

		// Planar 8bit 4:2:0 video format.
		// The first buffer is an 8bpp luminance buffer.
		// Immediately following this is in interleaved buffer of 8bpp Cb, Cr pairs
		NDIlib_FourCC_video_type_NV12 = (ord('N') or (ord('V') shl 8) or (ord('1') shl 16) or (ord('2') shl 24)), //NDI_LIB_FOURCC('N', 'V', '1', '2'),
		NDIlib_FourCC_type_NV12 = NDIlib_FourCC_video_type_NV12,

		// Planar 8bit, 4:4:4:4 video format.
		// Color ordering in memory is blue, green, red, alpha
		NDIlib_FourCC_video_type_BGRA = (ord('B') or (ord('G') shl 8) or (ord('R') shl 16) or (ord('A') shl 24)), //NDI_LIB_FOURCC('B', 'G', 'R', 'A'),
		NDIlib_FourCC_type_BGRA = NDIlib_FourCC_video_type_BGRA,

		// Planar 8bit, 4:4:4 video format, packed into 32bit pixels.
		// Color ordering in memory is blue, green, red, 255
		NDIlib_FourCC_video_type_BGRX = (ord('B') or (ord('G') shl 8) or (ord('R') shl 16) or (ord('X') shl 24)), //NDI_LIB_FOURCC('B', 'G', 'R', 'X'),
		NDIlib_FourCC_type_BGRX = NDIlib_FourCC_video_type_BGRX,

		// Planar 8bit, 4:4:4:4 video format.
		// Color ordering in memory is red, green, blue, alpha
		NDIlib_FourCC_video_type_RGBA = (ord('R') or (ord('G') shl 8) or (ord('B') shl 16) or (ord('A') shl 24)), //NDI_LIB_FOURCC('R', 'G', 'B', 'A'),
		NDIlib_FourCC_type_RGBA = NDIlib_FourCC_video_type_RGBA,

		// Planar 8bit, 4:4:4 video format, packed into 32bit pixels.
		// Color ordering in memory is red, green, blue, 255
		NDIlib_FourCC_video_type_RGBX = (ord('R') or (ord('G') shl 8) or (ord('B') shl 16) or (ord('X') shl 24)), //NDI_LIB_FOURCC('R', 'G', 'B', 'X'),
		NDIlib_FourCC_type_RGBX = NDIlib_FourCC_video_type_RGBX,

		// Ensure that the size is 32bits
		NDIlib_FourCC_video_type_max = $7fffffff
	);
  
// Really for backwards compatibility
type
	TNDIlib_FourCC_type = TNDIlib_FourCC_video_type;

	// FourCC values for audio frames
	TNDIlib_FourCC_audio_type =
	(
		// Planar 32-bit floating point. Be sure to specify the channel stride.
		NDIlib_FourCC_audio_type_FLTP = (ord('F') or (ord('L') shl 8) or (ord('T') shl 16) or (ord('P') shl 24)), //NDI_LIB_FOURCC('F', 'L', 'T', 'p'),
		NDIlib_FourCC_type_FLTP = NDIlib_FourCC_audio_type_FLTP,

		// Ensure that the size is 32bits
		NDIlib_FourCC_audio_type_max = $7fffffff
	);
	
	TNDIlib_frame_format_type =
	(
		// A progressive frame
		NDIlib_frame_format_type_progressive = 1,

		// A fielded frame with the field 0 being on the even lines and field 1 being
		// on the odd lines/
		NDIlib_frame_format_type_interleaved = 0,

		// Individual fields
		NDIlib_frame_format_type_field_0 = 2,
		NDIlib_frame_format_type_field_1 = 3,

		// Ensure that the size is 32bits
		NDIlib_frame_format_type_max = $7fffffff
	);


// When you specify this as a timecode, the timecode will be synthesized for you. This may
// be used when sending video, audio or metadata. If you never specify a timecode at all,
// asking for each to be synthesized, then this will use the current system time as the 
// starting timecode and then generate synthetic ones, keeping your streams exactly in 
// sync as long as the frames you are sending do not deviate from the system time in any 
// meaningful way. In practice this means that if you never specify timecodes that they 
// will always be generated for you correctly. Timecodes coming from different senders on 
// the same machine will always be in sync with each other when working in this way. If you 
// have NTP installed on your local network, then streams can be synchronized between 
// multiple machines with very high precision.
// 
// If you specify a timecode at a particular frame (audio or video), then ask for all subsequent 
// ones to be synthesized. The subsequent ones will be generated to continue this sequence 
// maintaining the correct relationship both the between streams and samples generated, avoiding
// them deviating in time from the timecode that you specified in any meaningful way.
//
// If you specify timecodes on one stream (e.g. video) and ask for the other stream (audio) to 
// be synthesized, the correct timecodes will be generated for the other stream and will be synthesize
// exactly to match (they are not quantized inter-streams) the correct sample positions.
//
// When you send metadata messages and ask for the timecode to be synthesized, then it is chosen
// to match the closest audio or video frame timecode so that it looks close to something you might
// want ... unless there is no sample that looks close in which a timecode is synthesized from the 
// last ones known and the time since it was sent.
//
const
	NDIlib_send_timecode_synthesize : int64 = 9223372036854775807;
  
	// If the time-stamp is not available (i.e. a version of a sender before v2.5)
	NDIlib_recv_timestamp_undefined :int64 = 9223372036854775807;


// This is a descriptor of a NDI source available on the network.
type
	pNDIlib_source = ^TNDIlib_source;
	TNDIlib_source = record
		// A UTF8 string that provides a user readable name for this source.
		// This can be used for serialization, etc... and comprises the machine
		// name and the source name on that machine. In the form
		//     MACHINE_NAME (NDI_SOURCE_NAME)
		// If you specify this parameter either as NULL, or an EMPTY string then the 
		// specific IP address and port number from below is used.
		p_ndi_name : PAnsiChar;

		// A UTF8 string that provides the actual network address and any parameters. 
		// This is not meant to be application readable and might well change in the future.
		// This can be NULL if you do not know it and the API internally will instantiate
		// a finder that is used to discover it even if it is not yet available on the network.

    // The current way of addressing the value
    p_url_address : PAnsiChar;

	end;

// This describes a video frame
type
	pNDIlib_video_frame_v2 = ^TNDIlib_video_frame_v2;
	TNDIlib_video_frame_v2 = record
		// The resolution of this frame
		xres, yres  : Integer;

		// What FourCC this is with. This can be two values
		FourCC : TNDIlib_FourCC_video_type;

		// What is the frame-rate of this frame.
		// For instance NTSC is 30000,1001 = 30000/1001 = 29.97fps
		frame_rate_N, frame_rate_D  : Integer;

		// What is the picture aspect ratio of this frame.
		// For instance 16.0/9.0 = 1.778 is 16:9 video
		picture_aspect_ratio  : Single;

		// Is this a fielded frame, or is it progressive
		frame_format_type: TNDIlib_frame_format_type;

		// The timecode of this frame in 100ns intervals
		timecode: Int64;

		// The video data itself
		p_data: PByte;

		// If the FourCC is not a compressed type, then this will be the
		// inter-line stride of the video data in bytes.  If the stride is 0,
		// then it will default to sizeof(one pixel)*xres.
		line_stride_in_bytes: Integer;

		// Per frame metadata for this frame. This is a NULL terminated UTF8 string
		// that should be in XML format. If you do not want any metadata then you
		// may specify NULL here.
		p_metadata: PAnsiChar; // Present in >= v2.5

		// This is only valid when receiving a frame and is specified as a 100ns
		// time that was the exact moment that the frame was submitted by the
		// sending side and is generated by the SDK. If this value is
		// NDIlib_recv_timestamp_undefined then this value is not available and
		// is NDIlib_recv_timestamp_undefined.
		timestamp: Int64; // Present in >= v2.5
	end;

// This describes an audio frame
type
	pNDIlib_audio_frame_v2 = ^TNDIlib_audio_frame_v2;
	TNDIlib_audio_frame_v2 = record
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
		
		// Per frame metadata for this frame. This is a NULL terminated UTF8 string
		// that should be in XML format. If you do not want any metadata then you
		// may specify NULL here.
		p_metadata: PAnsiChar; // Present in >= v2.5

		// This is only valid when receiving a frame and is specified as a 100ns
		// time that was the exact moment that the frame was submitted by the
		// sending side and is generated by the SDK. If this value is
		// NDIlib_recv_timestamp_undefined then this value is not available and
		// is NDIlib_recv_timestamp_undefined.
		timestamp: Int64; // Present in >= v2.5
	end;
	
// This describes an audio frame
type
	pNDIlib_audio_frame_v3 = ^TNDIlib_audio_frame_v3;
	TNDIlib_audio_frame_v3 = record
		// The sample-rate of this buffer
		sample_rate: Integer;

		// The number of audio channels
		no_channels: Integer;

		// The number of audio samples per channel
		no_samples: Integer;

		// The timecode of this frame in 100ns intervals
		timecode: Int64;

		// What FourCC describing the type of data for this frame
		FourCC: TNDIlib_FourCC_audio_type;

		// The audio data
		p_data: PByte;

		// If the FourCC is not a compressed type and the audio format is planar,
		// then this will be the stride in bytes for a single channel.
		channel_stride_in_bytes: Integer;

		// Per frame metadata for this frame. This is a NULL terminated UTF8 string
		// that should be in XML format. If you do not want any metadata then you
		// may specify NULL here.
		p_metadata: PAnsiChar;

		// This is only valid when receiving a frame and is specified as a 100ns
		// time that was the exact moment that the frame was submitted by the
		// sending side and is generated by the SDK. If this value is
		// NDIlib_recv_timestamp_undefined then this value is not available and
		// is NDIlib_recv_timestamp_undefined.
		timestamp: Int64;
	end;

// The data description for metadata
type
	pNDIlib_metadata_frame = ^TNDIlib_metadata_frame;
	TNDIlib_metadata_frame = record
		// The length of the string in UTF8 characters. This includes the NULL terminating character.
		// If this is 0, then the length is assume to be the length of a NULL terminated string.
		length: Integer;

		// The timecode of this frame in 100ns intervals
		timecode: int64;

		// The metadata as a UTF8 XML string. This is a NULL terminated string.
		p_data: PAnsiChar;
	end;

// Tally structures
type
	pNDIlib_tally = ^TNDIlib_tally;
	TNDIlib_tally = record
		// Is this currently on program output
		on_program: LongBool;

		// Is this currently on preview output
		on_preview: LongBool;
	end;


{$endif} (* PROCESSING_NDI_STRUCTS_H *)
