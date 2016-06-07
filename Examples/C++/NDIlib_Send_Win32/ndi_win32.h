#pragma once

struct win32_to_ndi
{			// Constructor
			win32_to_ndi(const char* p_ndi_name, const int xres = 1920, const int yres = 1080, const int framerate_n = 30000, const int framerate_d = 1001);

			// Desstructor
			~win32_to_ndi(void);

			// Was there an error creating it
			const bool error(void) const;

			// Begin drawing
			HDC begin(const bool clear = true);

			// Finish drawing
			void end(void);

private:	// The off screen device context that we can paint too
			HDC m_hdc;

			// The HBITMAP
			HBITMAP m_hBMP[2], m_hBMP_old;
			BYTE* m_p_data[2];

			// The size
			const int m_xres, m_yres;
			const int m_framerate_n, m_framerate_d;

			// A UYVY buffer
			BYTE* m_p_uyvy;

			// The NDI sender
			NDIlib_send_instance_t m_pNDI_send;
};