{$ifndef PROCESSING_NDI_ROUTING_H}
	{$define PROCESSING_NDI_ROUTING_H}

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

// Structures and type definitions required by NDI sending
// The reference to an instance of the sender
type
	pNDIlib_routing_instance = Pointer;

// The creation structure that is used when you are creating a sender
type
	pNDIlib_routing_create = ^TNDIlib_routing_create;
	TNDIlib_routing_create = record
		// The name of the NDI source to create. This is a NULL terminated UTF8 string.
		p_ndi_name: PAnsiChar;

		// What groups should this source be part of
		p_groups: PAnsiChar;
	end;

// Create an NDI routing source
function NDIlib_routing_create(p_create_settings: pNDIlib_routing_create): pNDIlib_routing_instance;
	cdecl; external PROCESSINGNDILIB_API;
	
// Destroy and NDI routing source
procedure NDIlib_routing_destroy(p_instance: pNDIlib_routing_instance);
	cdecl; external PROCESSINGNDILIB_API;
	
// Change the routing of this source to another destination
function NDIlib_routing_change(p_instance: pNDIlib_routing_instance; p_source: pNDIlib_source): LongBool;
	cdecl; external PROCESSINGNDILIB_API;
	
// Change the routing of this source to another destination
function NDIlib_routing_clear(p_instance: pNDIlib_routing_instance): LongBool;
	cdecl; external PROCESSINGNDILIB_API;
	
// Get the current number of receivers connected to this source. This can be used to avoid even rendering when nothing is connected to the video source. 
// which can significantly improve the efficiency if you want to make a lot of sources available on the network. If you specify a timeout that is not
// 0 then it will wait until there are connections for this amount of time.
function NDIlib_routing_get_no_connections(p_instance: pNDIlib_routing_instance; timeout_in_ms: Cardinal): Integer;
	cdecl; external PROCESSINGNDILIB_API;
	
// Retrieve the source information for the given router instance.  This pointer is valid until NDIlib_routing_destroy is called.
function NDIlib_routing_get_source_name(p_instance: pNDIlib_routing_instance): pNDIlib_source;
	cdecl; external PROCESSINGNDILIB_API;

{$endif} (* PROCESSING_NDI_ROUTING_H *)
