#pragma once

#ifdef FILEREADERSDK_EXPORTS
#define FILEREADERSDK_API __declspec(dllexport)
#else
#define FILEREADERSDK_API __declspec(dllimport)

#ifdef	_MSC_VER
#ifdef	_WIN64
#pragma comment(lib, "Processing.FileReader.SDK.x64.lib")
#else	// _WIN64
#pragma comment(lib, "Processing.FileReader.SDK.x86.lib")
#endif	// _WIN64
#endif	// _MSC_VER

#endif

// Include the structures used by the file reader
#include "FileReaderSDK_structs.h"

// Create a file reader instance for the file
// If the file cannot be opened, this will return NULL, otherwise it will return the handle that may be used for p_instance in all other function calls.
extern "C" FILEREADERSDK_API
void* FileReader_Create(const wchar_t* filename);

// Destroy the file reader instance
extern "C" FILEREADERSDK_API
void FileReader_Destroy(void* p_instance);

// Get information regarding the file reader instance
// Returns TRUE if the information was obtained successfully, or FALSE if information is not available yet.
extern "C" FILEREADERSDK_API
bool FileReader_GetInfo(void* p_instance, FileReader_Info* p_info);

// Retrieve a UYVY frame from the file reader instance
// The memory pointed to by p_ycbcr needs to be large enough for a UYVY frame at the resolution returned by FileReader_GetInfo
// The xres stride needs to be aligned to a 16-byte boundary
// Returns TRUE if the frame could be read successfully
extern "C" FILEREADERSDK_API
bool FileReader_GetFrameYCbCr(void* p_instance, const __int64 frame_num, BYTE* p_ycbcr, const int stride_in_bytes);

// Retrieve a BGRA frame from the file reader instance
// If flipped is true, then the image is read bottom to top, instead of top to bottom.
// The memory pointed to by p_bgra needs to be large enough for a BGRA frame at the resolution returned by FileReader_GetInfo
// Returns TRUE if the frame could be read successfully
extern "C" FILEREADERSDK_API
bool FileReader_GetFrameBGRA(void* p_instance, const __int64 frame_num, BYTE* p_bgra, const int stride_in_bytes, const bool flipped);

// Retrieve audio samples from the file reader instance
// The memory pointed to by p_samples needs to be large enough for num_samples worth of audio given the number of audio channels from FileReader_GetInfo
// Returns TRUE if audio could be read and p_num_samples_read will be set to the number of samples read, or FALSE if no audio could be read
extern "C" FILEREADERSDK_API
bool FileReader_GetSamples(void* p_instance, const __int64 sample_num, const int num_samples, short* p_samples, int* p_num_samples_read);

// Convert the frame number to its corresponding time code
// The time code is in 100-nanosecond units, base 10000000LL
extern "C" FILEREADERSDK_API
bool FileReader_TimeCode_from_FrameNumber(void* p_instance, const __int64 frame_num, __int64* p_timecode);

// Convert the time code to its corresponding frame number
// The time code is in 100-nanosecond units, base 10000000LL
extern "C" FILEREADERSDK_API
bool FileReader_FrameNumber_from_TimeCode(void* p_instance, const __int64 timecode, __int64* p_frame_num);
