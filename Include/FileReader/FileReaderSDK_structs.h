#pragma once

// THis structure describes the current state of a video file.
struct FileReader_Info
{
	bool    updating;     // Is the file being written to?
						  // If this is TRUE, then file file is still currently a growing file, probably because
						  // a 3Play or TriCaster system is still recording to it. Each time you call GetInfo 
						  // the num_frames and num_samples function will show you the length of the file at that
						  // instance in time.

	__int64 num_frames;   // Number of frames in the file
	int     xres;         // Width of the frames in pixels.
	int     yres;         // Height of the frames in pixels.
	int     frame_rate_n; // Frame rate numerator. Frame frame rate as a float might be (float)frame_rate_n/(float)frame_rate_d
	int     frame_rate_d; // Frame rate denominator
	bool    progressive;  // Progressive video or not. If this is false, the video is fielded.
	float   aspect_ratio; // Aspect ratio. For instance, 4:3 video is 4.0/3.0=1.3333333

	bool    has_audio;    // Is audio present?
	__int64 num_samples;  // Number of audio samples in the file.
	int     num_channels; // Number of channels in the audio.
	int     sample_rate;  // Sample rate of the audio.
};