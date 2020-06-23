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

unit Processing.NDI.Lib;

{$MINENUMSIZE 4}

interface


uses
  System.SysUtils,
  System.Types;

const
  {$IFDEF WIN32}
    PROCESSINGNDILIB_API = 'Processing.NDI.Lib.x86.dll';
  {$ENDIF}
  {$IFDEF WIN64}
    PROCESSINGNDILIB_API = 'Processing.NDI.Lib.x64.dll';
  {$ENDIF}

  {$IFDEF WINDOWS}

  {$ENDIF}

  {$IFDEF UNIX}
    {$IFDEF DARWIN}
      PROCESSINGNDILIB_API = 'libndi.dylib';
    {$ELSE}
      {$IFDEF FPC}
        PROCESSINGNDILIB_API = 'libndi.so';
      {$ELSE}
        PROCESSINGNDILIB_API = 'libndi.so.0';
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF MACOS}
    PROCESSINGNDILIB_API = 'libndi.dylib';
  {$ENDIF}


// Data structures shared by multiple SDKs
{$I Processing.NDI.compat.pas}
{$I Processing.NDI.structs.pas}

// This is not actually required, but will start and end the libraries which might get
// you slightly better performance in some cases. In general it is more "correct" to 
// call these although it is not required. There is no way to call these that would have
// an adverse impact on anything (even calling destroy before you've deleted all your
// objects). This will return false if the CPU is not sufficiently capable to run NDILib
// currently NDILib requires SSE4.2 instructions (see documentation). You can verify 
// a specific CPU against the library with a call to NDIlib_is_supported_CPU()
function NDIlib_initialize(): LongBool;
  cdecl; external PROCESSINGNDILIB_API;

procedure NDIlib_destroy();
  cdecl; external PROCESSINGNDILIB_API;

function NDIlib_version(): PAnsiChar;
  cdecl; external PROCESSINGNDILIB_API;

// Recover whether the current CPU in the system is capable of running NDILib.
function NDIlib_is_supported_CPU(): LongBool;
  cdecl; external PROCESSINGNDILIB_API;

// The finding (discovery API)
{$I Processing.NDI.Find.pas}

// The receiving video and audio API
{$I Processing.NDI.Recv.pas}

// Extensions to support PTZ control, etc...
{$I Processing.NDI.Recv.ex.pas}

// The sending video API
{$I Processing.NDI.Send.pas}

// The routing of inputs API
{$I Processing.NDI.Routing.pas}

// Utility functions
{$I Processing.NDI.utilities.pas}

// Deprecated structures and functions
{$I Processing.NDI.deprecated.pas}

// The frame synchronizer
{$I Processing.NDI.FrameSync.pas}

implementation

end.

