#pragma once

// An enumeration to specify the type of a packet returned by the functions
enum NDIlib_frame_type_e : DWORD
{	NDIlib_frame_type_none = 0,
	NDIlib_frame_type_video = 1,
	NDIlib_frame_type_audio = 2,
	NDIlib_frame_type_metadata = 3,
	NDIlib_frame_type_error = 4
};

enum NDIlib_FourCC_type_e : DWORD
{	NDIlib_FourCC_type_UYVY = 'YVYU',
	NDIlib_FourCC_type_BGRA = 'ARGB'
};

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
static const LONGLONG NDIlib_send_timecode_synthesize = 9223372036854775807LL; // = INT64_MAX

// This is a descriptor of a NDI source available on the network.
struct NDIlib_source_t
{	// A UTF8 string that provides a user readable name for this source.
	// This can be used for serialization, etc... and comprises the machine
	// name and the source name on that machine. In the form
	//		MACHINE_NAME (NDI_SOURCE_NAME)
	// If you specify this parameter either as NULL, or an EMPTY string then the 
	// specific ip addres adn port number from below is used.
	const CHAR* p_ndi_name;

	// A UTF8 string that provides the actual IP address and port number. 
	// This is in the form : IP_ADDRESS:PORT_NO, for instance "127.0.0.1:10000"
	// If you leave this parameter either as NULL, or an EMPTY string then the 
	// ndi name above is used to look up the mDNS name to determine the IP and 
	// port number. Connection is faster if the IP address is known.
	const CHAR* p_ip_address;
};

// This describes a video frame
struct NDIlib_video_frame_t
{	// The resolution of this frame
	DWORD xres, yres;

	// What FourCC this is with. This can be two values
	NDIlib_FourCC_type_e FourCC;

	// What is the frame-rate of this frame.
	// For instance NTSC is 30000,1001 = 30000/1001 = 29.97fps
	DWORD frame_rate_N, frame_rate_D;

	// What is the picture aspect ratio of this frame.
	// For instance 16.0/9.0 = 1.778 is 16:9 video
	FLOAT picture_aspect_ratio;

	// Is this a fielded frame, or is it progressive
	BOOL is_progressive;

	// The timecode of this frame in 100ns intervals
	LONGLONG timecode;

	// The video data itself
	BYTE* p_data;

	// The inter line stride of the video data, in bytes.
	DWORD line_stride_in_bytes;
};

// This describes an audio frame
struct NDIlib_audio_frame_t
{	// The sample-rate of this buffer
	DWORD sample_rate;

	// The number of audio channels
	DWORD no_channels;

	// The number of audio samples per channel
	DWORD no_samples;

	// The timecode of this frame in 100ns intervals
	LONGLONG timecode;

	// The audio data
	FLOAT* p_data;

	// The inter channel stride of the audio channels, in bytes
	DWORD channel_stride_in_bytes;
};

// The data description for metadata
struct NDIlib_metadata_frame_t
{	// The length of the string in UTF8 characters.This includes the NULL terminating character.
	DWORD length;

	// The timecode of this frame in 100ns intervals
	LONGLONG timecode;

	// The metadata as a UTF8 XML string. This is a NULL terminated string.
	CHAR* p_data;
};

// Tally structures
struct NDIlib_tally_t
{	// Is this currently on program output
	BOOL on_program;

	// Is this currently on preview output
	BOOL on_preview;
};