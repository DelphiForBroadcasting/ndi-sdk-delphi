{$ifndef PROCESSING_NDI_UTILITIES_H}
	{$define PROCESSING_NDI_UTILITIES_H}

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
	pNDIlib_audio_frame_interleaved_16s = ^TNDIlib_audio_frame_interleaved_16s;
	TNDIlib_audio_frame_interleaved_16s = record
		// The sample-rate of this buffer
		sample_rate : Integer;

		// The number of audio channels
		no_channels : Integer;

		// The number of audio samples per channel
		no_samples : Integer;

		// The timecode of this frame in 100ns intervals
		timecode: Int64;

		// The audio reference level in dB. This specifies how many dB above the reference level (+4dBU) is the full range of 16 bit audio.
		// If you do not understand this and want to just use numbers :
		//		-	If you are sending audio, specify +0dB. Most common applications produce audio at reference level.
		//		-	If receiving audio, specify +20dB. This means that the full 16 bit range corresponds to professional level audio with 20dB of headroom. Note that
		//			if you are writing it into a file it might sound soft because you have 20dB of headroom before clipping.
		reference_level: Integer;

		// The audio data, interleaved 16bpp
		p_data : PShortInt;
	end;

// This describes an audio frame
type
	pNDIlib_audio_frame_interleaved_32s = ^TNDIlib_audio_frame_interleaved_32s;
	TNDIlib_audio_frame_interleaved_32s = record
		// The sample-rate of this buffer
		sample_rate: Integer;

		// The number of audio channels
		no_channels: Integer;

		// The number of audio samples per channel
		no_samples: Integer;

		// The timecode of this frame in 100ns intervals
		timecode: Int64;

		// The audio reference level in dB. This specifies how many dB above the reference level (+4dBU) is the full range of 16 bit audio. 
		// If you do not understand this and want to just use numbers :
		// - If you are sending audio, specify +0dB. Most common applications produce audio at reference level.
		// - If receiving audio, specify +20dB. This means that the full 16 bit range corresponds to professional level audio with 20dB of headroom. Note that
		//   if you are writing it into a file it might sound soft because you have 20dB of headroom before clipping.
		reference_level: Integer;

		// The audio data, interleaved 32bpp
		p_data: PInteger;
	end;

// This describes an audio frame
type
	pNDIlib_audio_frame_interleaved_32f = ^TNDIlib_audio_frame_interleaved_32f;
	TNDIlib_audio_frame_interleaved_32f = record
		// The sample-rate of this buffer
		sample_rate: Integer;

		// The number of audio channels
		no_channels: Integer;

		// The number of audio samples per channel
		no_samples: Integer;

		// The timecode of this frame in 100ns intervals
		timecode: Int64;
		
		// The audio data, interleaved 32bpp
		p_data: PSingle;
	end;


// This will add an audio frame in interleaved 16bpp
// This will add an audio frame
procedure NDIlib_util_send_send_audio_interleaved_16s(p_instance: pNDIlib_send_instance; p_audio_data: pNDIlib_audio_frame_interleaved_16s);
  cdecl; external PROCESSINGNDILIB_API;

// This will add an audio frame in interleaved 32bpp
procedure NDIlib_util_send_send_audio_interleaved_32s(p_instance: pNDIlib_send_instance; p_audio_data: pNDIlib_audio_frame_interleaved_32s);
  cdecl; external PROCESSINGNDILIB_API;
  
// This will add an audio frame in interleaved floating point
procedure NDIlib_util_send_send_audio_interleaved_32f(p_instance: pNDIlib_send_instance; p_audio_data: pNDIlib_audio_frame_interleaved_32f);
  cdecl; external PROCESSINGNDILIB_API;
  
// Convert to interleaved 16bpp
procedure NDIlib_util_audio_to_interleaved_16s_v2(p_src: pNDIlib_audio_frame_v2; p_dst: pNDIlib_audio_frame_interleaved_16s);
  cdecl; external PROCESSINGNDILIB_API;
  
// Convert from interleaved 16bpp
procedure NDIlib_util_audio_from_interleaved_16s_v2(p_src: pNDIlib_audio_frame_interleaved_16s; p_dst: pNDIlib_audio_frame_v2);
  cdecl; external PROCESSINGNDILIB_API;
  
// Convert to interleaved 32bpp
procedure NDIlib_util_audio_to_interleaved_32s_v2(p_src: pNDIlib_audio_frame_v2; p_dst: pNDIlib_audio_frame_interleaved_32s);
  cdecl; external PROCESSINGNDILIB_API;
  
// Convert from interleaved 32bpp
procedure NDIlib_util_audio_from_interleaved_32s_v2(p_src: pNDIlib_audio_frame_interleaved_32s; p_dst: pNDIlib_audio_frame_v2);
  cdecl; external PROCESSINGNDILIB_API;
  
// Convert to interleaved floating point
procedure NDIlib_util_audio_to_interleaved_32f_v2(p_src: pNDIlib_audio_frame_v2; p_dst: pNDIlib_audio_frame_interleaved_32f);
  cdecl; external PROCESSINGNDILIB_API;
  
// Convert from interleaved floating point
procedure NDIlib_util_audio_from_interleaved_32f_v2(p_src: pNDIlib_audio_frame_interleaved_32f; p_dst: pNDIlib_audio_frame_v2);
  cdecl; external PROCESSINGNDILIB_API;
  
// This is a helper function that you may use to convert from 10bit packed UYVY into 16bit semi-planar. The FourCC on the source 
// is ignored in this function since we do not define a V210 format in NDI. You must make sure that there is memory and a stride
// allocated in p_dst.
procedure NDIlib_util_V210_to_P216(p_src_v210: pNDIlib_video_frame_v2; p_dst_p216: pNDIlib_video_frame_v2);
  cdecl; external PROCESSINGNDILIB_API;
  
// This converts from 16bit semi-planar to 10bit. You must make sure that there is memory and a stride allocated in p_dst.
procedure NDIlib_util_P216_to_V210(p_src_p216: pNDIlib_video_frame_v2; p_dst_v210: pNDIlib_video_frame_v2);
  cdecl; external PROCESSINGNDILIB_API;

{$endif} (* PROCESSING_NDI_UTILITIES_H *)
