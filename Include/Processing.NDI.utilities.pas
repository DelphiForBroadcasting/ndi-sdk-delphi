{$ifndef PROCESSING_NDI_UTILITIES_H}
	{$define PROCESSING_NDI_UTILITIES_H}

// Because many applications like submitting 16bit interleaved audio, these functions will convert in
// and out of that format. It is important to note that the NDI SDK does define fully audio levels, something
// that most applications that you use do not. Specifically, the floating point -1.0 to +1.0 range is defined
// as a professional audio reference level of +4dBU. If we take 16bit audio and scale it into this range
// it is almost always correct for sending and will cause no problems. For receiving however it is not at
// all uncommon that the user has audio that exceeds reference level and in this case it is likely that audio
// exceeds the reference level and so if you are not careful you will end up having audio clipping when
// you use the 16 bit range.

// This describes an audio frame
type
  PNDIlib_audio_frame_interleaved_16s = ^TNDIlib_audio_frame_interleaved_16s;
  TNDIlib_audio_frame_interleaved_16s = record
    // The sample-rate of this buffer
    sample_rate : cardinal;

    // The number of audio channels
    no_channels : cardinal;

    // The number of audio samples per channel
    no_samples : cardinal;

    // The timecode of this frame in 100ns intervals
    timecode: Int64;

    // The audio reference level in dB. This specifies how many dB above the reference level (+4dBU) is the full range of 16 bit audio.
    // If you do not understand this and want to just use numbers :
    //		-	If you are sending audio, specify +0dB. Most common applications produce audio at reference level.
    //		-	If receiving audio, specify +20dB. This means that the full 16 bit range corresponds to professional level audio with 20dB of headroom. Note that
    //			if you are writing it into a file it might sound soft because you have 20dB of headroom before clipping.
    reference_level: cardinal;

    // The audio data, interleaved 16bpp
    p_data : PShortInt;
  end;


// This will add an audio frame
procedure NDIlib_util_send_send_audio_interleaved_16s(p_instance: TNDIlib_send_instance; p_audio_data: PNDIlib_audio_frame_interleaved_16s);
  cdecl; external PROCESSINGNDILIB_API;

// Convert an planar floating point audio buffer into a interleaved short audio buffer.
// IMPORTANT : You must allocate the space for the samples in the destination to allow for your own memory management.
procedure NDIlib_util_audio_to_interleaved_16s(p_src: PNDIlib_audio_frame; p_dst: PNDIlib_audio_frame_interleaved_16s);
  cdecl; external PROCESSINGNDILIB_API;

// Convert an interleaved short audio buffer audio buffer into a planar floating point one.
// IMPORTANT : You must allocate the space for the samples in the destination to allow for your own memory management.
procedure NDIlib_util_audio_from_interleaved_16s(p_src: PNDIlib_audio_frame_interleaved_16s; p_dst: PNDIlib_audio_frame);
  cdecl; external PROCESSINGNDILIB_API;

{$endif} (* PROCESSING_NDI_UTILITIES_H *)
