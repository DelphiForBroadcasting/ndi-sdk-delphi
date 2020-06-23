{$ifndef PROCESSING_NDI_FIND_H}
	{$define PROCESSING_NDI_FIND_H}

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

// Structures and type definitions required by NDI finding
// The reference to an instance of the finder
type
	pNDIlib_find_instance = Pointer;


// The creation structure that is used when you are creating a finder
type
	pNDIlib_find_create = ^TNDIlib_find_create;
	TNDIlib_find_create = packed record
		// Do we want to incluide the list of NDI sources that are running
		// on the local machine ?
		// If TRUE then local sources will be visible, if FALSE then they
		// will not.
		show_local_sources: integer;

		  // Which groups do you want to search in for sources
		p_groups: PAnsiChar;
			// The list of additional IP addresses that exist that we should query for 
		// sources on. For instance, if you want to find the sources on a remote machine
		// that is not on your local sub-net then you can put a comma separated list of 
		// those IP addresses here and those sources will be available locally even though
		// they are not mDNS discoverable. An example might be "12.0.0.8,13.0.12.8".
		// When none is specified the registry is used.
		// Default = NULL;
		p_extra_ips: PAnsiChar;
	end;


//**************************************************************************************************************************
// Create a new finder instance. This will return NULL if it fails.

function NDIlib_find_create_v2(p_create_settings: pNDIlib_find_create = nil): pNDIlib_find_instance;
	cdecl; external PROCESSINGNDILIB_API;

// This will destroy an existing finder instance.
procedure NDIlib_find_destroy(p_instance: pNDIlib_find_instance);
	cdecl; external PROCESSINGNDILIB_API;
  
// This function will recover the current set of sources (i.e. the ones that exist right this second).
// The char* memory buffers returned in NDIlib_source_t are valid until the next call to NDIlib_find_get_current_sources or a call to NDIlib_find_destroy.
// For a given NDIlib_find_instance_t, do not call NDIlib_find_get_current_sources asynchronously.

function NDIlib_find_get_current_sources(p_instance: pNDIlib_find_instance; var p_no_sources: Cardinal): pNDIlib_source;
	cdecl; external PROCESSINGNDILIB_API;
	
// This will allow you to wait until the number of online sources have changed.
function NDIlib_find_wait_for_sources(p_instance: pNDIlib_find_instance; timeout_in_ms: Cardinal): LongBool
	cdecl; external PROCESSINGNDILIB_API;

{$endif} (* PROCESSING_NDI_FIND_H *)
