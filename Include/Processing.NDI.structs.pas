{$ifndef PROCESSING_NDI_STRUCTS_H}
	{$define PROCESSING_NDI_STRUCTS_H}

type
// An enumeration to specify the type of a packet returned by the functions
  TNDIlib_frame_type_e = (
    NDIlib_frame_type_none = $00000000,
    NDIlib_frame_type_video = $00000001,
    NDIlib_frame_type_audio = $00000002,
    NDIlib_frame_type_metadata = $00000003,
    NDIlib_frame_type_error = $00000004
  );

  TNDIlib_FourCC_type_e = (
	  NDIlib_FourCC_type_UYVY = $59565955,  //YVYU
	  NDIlib_FourCC_type_BGRA = $41524742,  // ARGB
	  NDIlib_FourCC_type_BGRX = $58524742   // XRGB
  );

// When you specify this as a timecode, the timecode will be synthesized for you. This may
// be used when sending video, audio or metadata. If you never specify a timecode at all,
// asking for each to be synthesized, then this will use the current system time as the
// starting timecode and then generate synthetic ones, keeping your streams exactly in
// sync as long as the frames you are sending do not deviate from the system time in any
// meaningful way. In practice this means that if you never specify timecodes that they
// will always be generated for you correctly. Timecodes coming from different senders on
// the same machine will always be in sync with eachother when working in this way. If you
// have NTP installed on your local network, then streams can be synchronized between
// multiple machines with very high precision.
//
// If you specify a timecode at a particular frame (audio or video), then ask for all subsequent
// ones to be synthesized. The subsequent ones will be generated to continue this sequency
// maintining the correct relationship both the between streams and samples generated, avoiding
// them deviating in time from teh timecode that you specified in any meanginfful way.
//
// If you specify timecodes on one stream (e.g. video) and ask for the other stream (audio) to
// be sythesized, the correct timecodes will be generated for the other stream and will be synthesize
// exactly to match (they are not quantized inter-streams) the correct sample positions.
//
// When you send metadata messagesa and ask for the timecode to be synthesized, then it is chosen
// to match the closest audio or video frame timecode so that it looks close to something you might
// want ... unless there is no sample that looks close in which a timecode is synthesized from the
// last ones known and the time since it was sent.
//
const
  NDIlib_send_timecode_synthesize : int64 = 9223372036854775807;

// This is a descriptor of a NDI source available on the network.
type
  PNDIlib_source = ^TNDIlib_source;
  TNDIlib_source = record
	// A UTF8 string that provides a user readable name for this source.
	// This can be used for serialization, etc... and comprises the machine
	// name and the source name on that machine. In the form
	//		MACHINE_NAME (NDI_SOURCE_NAME)
	// If you specify this parameter either as NULL, or an EMPTY string then the
	// specific ip addres adn port number from below is used.
    p_ndi_name : PAnsiChar;

	// A UTF8 string that provides the actual IP address and port number.
	// This is in the form : IP_ADDRESS:PORT_NO, for instance "127.0.0.1:10000"
	// If you leave this parameter either as NULL, or an EMPTY string then the
	// ndi name above is used to look up the mDNS name to determine the IP and
	// port number. Connection is faster if the IP address is known.
    p_ip_address : PAnsiChar;
  end;

// This describes a video frame
type
  PNDIlib_video_frame = ^TNDIlib_video_frame;
  TNDIlib_video_frame = record
    // The resolution of this frame
    xres, yres  : Cardinal;

    // What FourCC this is with. This can be two values
    FourCC : TNDIlib_FourCC_type_e;

    // What is the frame-rate of this frame.
    // For instance NTSC is 30000,1001 = 30000/1001 = 29.97fps
    frame_rate_N, frame_rate_D  : Cardinal;

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
    line_stride_in_bytes: Cardinal;
  end;

// This describes an audio frame
type
  PNDIlib_audio_frame = ^TNDIlib_audio_frame;
  TNDIlib_audio_frame = record
  	// The sample-rate of this buffer
    sample_rate: Cardinal;

    // The number of audio channels
    no_channels: Cardinal;

    // The number of audio samples per channel
    no_samples: Cardinal;

    // The timecode of this frame in 100ns intervals
    timecode: int64;

    // The audio data
    p_data: PSingle;

    // The inter channel stride of the audio channels, in bytes
    channel_stride_in_bytes: Cardinal;
  end;

// The data description for metadata
type
  PNDIlib_metadata_frame = ^TNDIlib_metadata_frame;
  TNDIlib_metadata_frame = record
    // The length of the string in UTF8 characters.This includes the NULL terminating character.
	  length: Cardinal;

	  // The timecode of this frame in 100ns intervals
	  timecode: int64;

	  // The metadata as a UTF8 XML string. This is a NULL terminated string.
	  p_data: PAnsiChar;
  end;

// Tally structures
type
  PNDIlib_tally = ^TNDIlib_tally;
  TNDIlib_tally = record
	  // Is this currently on program output
	  on_program: integer;

	  // Is this currently on preview output
	  on_preview : integer;
  end;


{$endif} (* PROCESSING_NDI_STRUCTS_H *)
