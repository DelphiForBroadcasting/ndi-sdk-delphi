// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <tchar.h>

#ifndef NOMINMAX
#	define NOMINMAX
#	ifdef max
#		undef max
#	endif
#	ifdef min
#		undef min
#	endif
#endif

#include <math.h>
#include <windows.h>
#include <algorithm>


// TODO: reference additional headers your program requires here
#pragma comment(lib,"Winmm.lib")