//-------------------------------------------------------------------------------------------------------------------
// (c)2016 NewTek, inc.
//
// This library is provided under the license terms that are provided within the 
// NDI SDK installer. If you do not expressely agree to these terms then this library
// may be used for no purpose at all.
//
// For any questions or comments please email: ndi@newtek.com
// 
//-------------------------------------------------------------------------------------------------------------------

// Is this library being compiled, or imported by another application.

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
{$I Processing.NDI.structs.pas}

// This is not actually required, but will start and end the libraries which might get
// you slightly better performance in some cases. In general it is more "correct" to
// call these although it is not required. There is no way to call these that would have
// an adverse impact on anything (even calling destroy before you've deleted all your
// objects). This will return false if the CPU is not sufficiently capable to run NDILib
// currently NDILib requires SSE4.2 instructions (see documentation). You can verify
// a specific CPU against the library with a call to NDIlib_is_supported_CPU()
function NDIlib_initialize(): integer;
  cdecl; external PROCESSINGNDILIB_API;

procedure NDIlib_destroy();
  cdecl; external PROCESSINGNDILIB_API;

function NDIlib_version(): PAnsiChar;
  cdecl; external PROCESSINGNDILIB_API;

// Recover whether the current CPU in the system is capable of running NDILib. Currently
// NDILib requires SSE4.1 https://en.wikipedia.org/wiki/SSE4 Creating devices when your
// CPU is not capable will return NULL and not crash. This function is provided to help
// understand why they cannot be created or warn users before they run.

function NDIlib_is_supported_CPU(): integer;
  cdecl; external PROCESSINGNDILIB_API;

// The main SDKs
{$I Processing.NDI.Find.pas}
{$I Processing.NDI.Recv.pas}
{$I Processing.NDI.Send.pas}

// Utility functions
{$I Processing.NDI.utilities.pas}

implementation

end.

