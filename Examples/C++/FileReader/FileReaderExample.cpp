#include "stdafx.h"
#include <FileReaderSDK.h>

// Allocate memory for a BGRA frame given resolution
static BYTE* alloc_bgra_frame(const int xres, const int yres, int* p_stride_in_bytes)
{
	const int stride_in_bytes = xres * 4;

	if (p_stride_in_bytes)
		*p_stride_in_bytes = stride_in_bytes;

	return new BYTE[stride_in_bytes * yres];
}

// Saves a BGRA image depending on the WIC type
static bool save_image(const wchar_t* filename, REFGUID wic_format_type, const int xres, const int yres, const int stride_in_bytes, BYTE* p_bgra_mem)
{
	// Initialize COM
	if (SUCCEEDED(CoInitialize(NULL)))
	{
		CComPtr<IWICImagingFactory> p_img_factory = nullptr;
		if (SUCCEEDED(p_img_factory.CoCreateInstance(CLSID_WICImagingFactory)))
		{
			// Create a bitmap wrapper around the buffer passed in
			CComPtr<IWICBitmap> p_bmp = nullptr;
			if (SUCCEEDED(p_img_factory->CreateBitmapFromMemory(xres, yres, GUID_WICPixelFormat32bppBGRA, stride_in_bytes, stride_in_bytes * yres, p_bgra_mem, &p_bmp)))
			{
				// Open a file stream
				CComPtr<IWICStream> p_file_stream = nullptr;
				if (SUCCEEDED(p_img_factory->CreateStream(&p_file_stream)) && SUCCEEDED(p_file_stream->InitializeFromFilename(filename, GENERIC_WRITE)))
				{
					// Create the image encoder
					CComPtr<IWICBitmapEncoder> p_encoder = nullptr;
					if (SUCCEEDED(p_img_factory->CreateEncoder(wic_format_type, NULL, &p_encoder)))
					{
						p_encoder->Initialize(p_file_stream, WICBitmapEncoderNoCache);

						// Writing the frame
						CComPtr<IWICBitmapFrameEncode> p_frame = nullptr;
						if (SUCCEEDED(p_encoder->CreateNewFrame(&p_frame, NULL)))
						{
							p_frame->Initialize(NULL);
							p_frame->WriteSource(p_bmp, NULL);
							p_frame->Commit();

							p_encoder->Commit();

							// All done and looking good
							CoUninitialize();
							return true;
						}
					}
				}
			}
		}
	}

	// Done with COM
	CoUninitialize();

	// The thumbnail didn't save
	return false;
}

// Saves a BGRA image as a JPEG
static bool save_jpg(const wchar_t* filename, const int xres, const int yres, const int stride_in_bytes, BYTE* p_bgra)
{
	return save_image(filename, GUID_ContainerFormatJpeg, xres, yres, stride_in_bytes, p_bgra);
}

// Generate a thumbnail using the File Reader SDK
static void generate_thumbnail(const wchar_t* filename, const __int64 frame_num)
{	// Create the reader instance
	void* p_reader = FileReader_Create(filename);
	if (!p_reader) return;

	// Obtain information about the file; wait until it's available if needed
	FileReader_Info info;
	while (!FileReader_GetInfo(p_reader, &info))
		Sleep(500);

	// Allocate memory for a single BGRA frame at the file's resolution
	int bgra_frame_stride;
	BYTE* p_bgra_frame = alloc_bgra_frame(info.xres, info.yres, &bgra_frame_stride);
	if (p_bgra_frame)
	{
		// Read 1 frame
		if (FileReader_GetFrameBGRA(p_reader, frame_num, p_bgra_frame, bgra_frame_stride, false))
		{
			// Swapping the file's original extension with .jpg and save the thumbnail
			wchar_t drive[_MAX_DRIVE], dir[_MAX_DIR], fname[_MAX_FNAME], ext[_MAX_EXT];
			if (_wsplitpath_s(filename, drive, dir, fname, ext) == 0)
			{
				wchar_t thumbnail_path[_MAX_PATH];
				if (_wmakepath_s(thumbnail_path, drive, dir, fname, L".jpg") == 0)
				{	// Save the thumbnail
					save_jpg(thumbnail_path, info.xres, info.yres, bgra_frame_stride, p_bgra_frame);
				}
			}
		}

		delete[] p_bgra_frame;
	}

	// Clean up
	FileReader_Destroy(p_reader);
}

int main(void)
{	// Generate a thumbnail	
	generate_thumbnail(L"Example File\\Example 1.mov", 0);

	// Finished
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
