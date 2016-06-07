#pragma once

//**************************************************************************************************************************
// Structures and type definitions required by NDI finding
// The reference to an instance of the finder
typedef void* NDIlib_find_instance_t;

// The creation structure that is used when you are creating a finder
struct NDIlib_find_create_t
{	// Do we want to incluide the list of NDI sources that are running
	// on the local machine ?
	// If TRUE then local sources will be visible, if FALSE then they
	// will not.
	BOOL show_local_sources;

	// Which groups do you want to search in for sources
	const CHAR* p_groups;
};

//**************************************************************************************************************************
// Create a new finder instance. This will return NULL if it fails.
extern "C" PROCESSINGNDILIB_API
NDIlib_find_instance_t NDIlib_find_create(const NDIlib_find_create_t* p_create_settings);

// This will destroy an existing finder instance.
extern "C" PROCESSINGNDILIB_API
void NDIlib_find_destroy(NDIlib_find_instance_t p_instance);

// This will recover the current set of located NDI sources. The string list is 
// retained as a member of the instance (so you do not need to worry about freeing it)
// and is valid until you call this function again. When the instance is destroyed
// the pointer is no longer valid either.
extern "C" PROCESSINGNDILIB_API
const NDIlib_source_t* NDIlib_find_get_sources(NDIlib_find_instance_t p_instance, DWORD *p_no_sources, const DWORD timeout_in_ms);