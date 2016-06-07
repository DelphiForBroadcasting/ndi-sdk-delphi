#include "stdafx.h"
#include <Processing.NDI.Lib.h>
#include "ndi_win32.h"

void draw_something(void)
{	// We are going to open a Win32 wrapper at 1920x1080 at 29.97fps
	const int xres = 1920;
	const int yres = 1080;
	const int framerate_n = 30000;
	const int framerate_d = 1001;

	win32_to_ndi output("NDI Test", xres, yres, framerate_n, framerate_d);
	if (output.error())
	{	printf("Cannot open GDI output.");
		return;
	}

	// We are going to need to allocate resources
	HDC hdc = output.begin(true);

	// We are going to need a black brush to clear the frame
	HFONT hFont = ::CreateFontW( 128, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_OUTLINE_PRECIS,
							     CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, VARIABLE_PITCH, L"Arial");

	// Select the font
	HFONT hFont_old = (HFONT)::SelectObject(hdc, hFont);
	::SetTextColor(hdc, RGB(255, 255, 255));
	::SetBkMode(hdc, TRANSPARENT);

	for (int x = 0, dx = (rand() & 7), cnt = 0;; x += dx)
	{	// Get the system time
		wchar_t temp[128];
		::swprintf(temp, 128, L"%06d", cnt++);
		
		// Draw some text
		::TextOutW(hdc, x, yres / 2, temp, (int)::wcslen(temp));

		// Bounce backwards and forwards
			 if (x > 1900 && dx > 0) dx = -(rand() & 7);
		else if (x < 20 && dx < 0)	 dx = +(rand() & 7);

		// Send it to output
		output.end();

		// Next frame
		hdc = output.begin(true);
	}

	// Old font
	::SelectObject(hdc, hFont_old);

	// Restore the old objects
	::DeleteObject(hFont);

	// Finish up
	output.end();
}

int _tmain(int argc, _TCHAR* argv[])
{	// Not required, but "correct" (see the SDK documentation.
	if (!NDIlib_initialize())
	{	// Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
		// you can check this directly with a call to NDIlib_is_supported_CPU()
		printf("Cannot run NDI.");
		return 0;
	}
	
	// Draw stuff !
	draw_something();

	// Not required, but nice
	NDIlib_destroy();

	// Finished
	return 0;
}

