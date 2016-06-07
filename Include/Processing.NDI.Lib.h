#pragma once

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
#ifdef PROCESSINGNDILIB_EXPORTS
#define PROCESSINGNDILIB_API __declspec(dllexport)
#else
#define PROCESSINGNDILIB_API __declspec(dllimport)

#ifdef	_MSC_VER
#ifdef	_WIN64
#pragma comment(lib, "Processing.NDI.Lib.x64.lib")
#else	// _WIN64
#pragma comment(lib, "Processing.NDI.Lib.x86.lib")
#endif	// _WIN64
#endif	// _MSC_VER

#endif

// Data structures shared by multiple SDKs
#include "Processing.NDI.structs.h"

// This is not actually required, but will start and end the libraries which might get
// you slightly better performance in some cases. In general it is more "correct" to 
// call these although it is not required. There is no way to call these that would have
// an adverse impact on anything (even calling destroy before you've deleted all your
// objects). This will return false if the CPU is not sufficiently capable to run NDILib
// currently NDILib requires SSE4.2 instructions (see documentation). You can verify 
// a specific CPU against the library with a call to NDIlib_is_supported_CPU()
extern "C" PROCESSINGNDILIB_API
const bool NDIlib_initialize(void);

extern "C" PROCESSINGNDILIB_API
void NDIlib_destroy(void);

extern "C" PROCESSINGNDILIB_API
const char* NDIlib_version(void);

// Recover whether the current CPU in the system is capable of running NDILib. Currently
// NDILib requires SSE4.1 https://en.wikipedia.org/wiki/SSE4 Creating devices when your 
// CPU is not capable will return NULL and not crash. This function is provided to help
// understand why they cannot be created or warn users before they run.
extern "C" PROCESSINGNDILIB_API
const bool NDIlib_is_supported_CPU(void);

// The main SDKs
#include "Processing.NDI.Find.h"
#include "Processing.NDI.Recv.h"
#include "Processing.NDI.Send.h"

// Utility functions
#include "Processing.NDI.utilities.h"
