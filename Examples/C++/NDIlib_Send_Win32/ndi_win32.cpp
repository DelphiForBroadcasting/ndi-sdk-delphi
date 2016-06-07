#include "stdafx.h"
#include <Processing.NDI.Lib.h>
#include "ndi_win32.h"

// An undocumented NDI lib function
const bool (*bgrx_to_uyvy_cond)( /* src */	const BYTE* __restrict p_src_bgrx, const int src_bgrx_stride,
								 /* src */	const BYTE* __restrict p_src_bgrx_old, const int src_bgrx_old_stride,
								 /* dst */	      BYTE*	__restrict p_dst_uyvy, const int dst_uyvy_stride,
								 /* N   */	const int xres, const int yres);

// Constructor
win32_to_ndi::win32_to_ndi(const char* p_ndi_name, const int xres, const int yres, const int framerate_n, const int framerate_d)
	:	m_hdc(::CreateCompatibleDC(NULL)),
		m_xres(xres), m_yres(yres),
		m_framerate_n(framerate_n),
		m_framerate_d(framerate_d),
		m_pNDI_send(NULL),
		m_hBMP_old(NULL),
		m_p_uyvy((BYTE*)_aligned_malloc(xres*yres * 2, 16))

{	// No HDC
	if (!m_hdc || !m_p_uyvy) return;

	// Load the undocumented fcn :)
#ifdef _WIN64
	HMODULE hLib = ::LoadLibraryW(L"Processing.NDI.Lib.x64.dll");
#else // _WIN64
	HMODULE hLib = ::LoadLibraryW(L"Processing.NDI.Lib.x86.dll");
#endif // _WIN64
	if (!hLib) return;

	// Get teh address of the BGRX to UYVY with conditional change support
	*(FARPROC*)&bgrx_to_uyvy_cond = ::GetProcAddress(hLib, "bgrx_to_uyvy_cond");

	// Clear the UYVY buffer
	::wmemset((wchar_t*)m_p_uyvy, 128 | (16 << 8), xres*yres);
	
	// Create a 32 bit bitmap
	BITMAPINFO bmi;
	bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bmi.bmiHeader.biWidth = xres;
	bmi.bmiHeader.biHeight = -yres;
	bmi.bmiHeader.biPlanes = 1;
	bmi.bmiHeader.biBitCount = 32;
	bmi.bmiHeader.biCompression = BI_RGB;
	bmi.bmiHeader.biSizeImage = xres*yres * 4;
	bmi.bmiHeader.biClrUsed = 0;
	bmi.bmiHeader.biClrImportant = 0;
	bmi.bmiHeader.biXPelsPerMeter = 0;
	bmi.bmiHeader.biYPelsPerMeter = 0;

	// Allocate two bitmaps
	for (int idx = 0; idx < 2; idx++)
	{	// Create the bitmap
		m_hBMP[idx] = ::CreateDIBSection(m_hdc, &bmi, DIB_RGB_COLORS, (void**)&m_p_data[idx], NULL, 0);
		if (!m_hBMP[idx]) return;

		// Clear the buffer
		::memset(m_p_data[idx], 0, xres*yres * 4);
	}

	// Create an NDI source that is called "My Video" and is clocked to the video.
	const NDIlib_send_create_t NDI_send_create_desc = { p_ndi_name, NULL, TRUE, FALSE };
	m_pNDI_send = ::NDIlib_send_create(&NDI_send_create_desc);
	if (!m_pNDI_send) return;
}

// Desstructor
win32_to_ndi::~win32_to_ndi(void)
{	// Just in case
	end();

	// Free UYVY buffer
	if (m_p_uyvy)
		::_aligned_free(m_p_uyvy);
	
	// Destroy the bitmap
	for (int idx = 0; idx < 2; idx++)
	if (m_hBMP[idx])
		::DeleteObject(m_hBMP[idx]);

	// Destroy the device contect
	if (m_hdc)
		::DeleteDC(m_hdc);

	// Destroy the NDI output
	if (m_pNDI_send)
		::NDIlib_send_destroy(m_pNDI_send);
}

// Was there an error creating it
const bool win32_to_ndi::error(void) const
{	// Check we got the HDC and the HBITMAP
	return (m_hdc && m_hBMP[0] && m_hBMP[1] && m_pNDI_send && bgrx_to_uyvy_cond) ? false : true;
}

// Begin drawing
HDC win32_to_ndi::begin(const bool clear)
{	// Clear the image if needed
	if (clear)
		::memset(m_p_data[0], 0, m_xres*m_yres * 4);

	// Select the new bitmap into place
	m_hBMP_old = (HBITMAP)::SelectObject(m_hdc, m_hBMP[0]);

	// Return teh HDC
	return m_hdc;
}

// Finish drawing
void win32_to_ndi::end(void)
{	// No previous bitmap
	if (!m_hBMP_old) return;

	// Restore the old bitmap
	::SelectObject(m_hdc, m_hBMP_old);
	m_hBMP_old = NULL;
	
	// OK, this is pretty cool. This function allows us to color convert into the buffer and it is optimized
	// to only do work that is needed. It then returns whether any pixels actually changed or not.
	const bool changes = bgrx_to_uyvy_cond( /* src */m_p_data[0], m_xres*4,
										    /* src */m_p_data[1], m_xres*4,
										    /* dst */m_p_uyvy, m_xres*2,
										    /* N   */m_xres, m_yres);
	
	// Describe the frame. Note another undocumented feature is that if you pass the pointer as NULL then it does not send the frame, 
	// but it does still clock it correctly as if you did :) I bet you are glad you are reading this example.
	const NDIlib_video_frame_t frame = { m_xres, m_yres, NDIlib_FourCC_type_UYVY, m_framerate_n, m_framerate_d, (float)m_xres / (float)m_yres,
										 TRUE, NDIlib_send_timecode_synthesize, changes ? m_p_uyvy : NULL, m_xres * 2 };
	
	// We now just send the frame
	if (m_pNDI_send)
		::NDIlib_send_send_video(m_pNDI_send, &frame);

	// Swap the buffers
	std::swap(m_p_data[0], m_p_data[1]);
	std::swap(m_hBMP[0], m_hBMP[1]);
}