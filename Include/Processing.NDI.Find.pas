{$ifndef PROCESSING_NDI_FIND_H}
	{$define PROCESSING_NDI_FIND_H}


//**************************************************************************************************************************
// Structures and type definitions required by NDI finding
// The reference to an instance of the finder
type
  PNDIlib_find_instance = ^TNDIlib_find_instance;
  TNDIlib_find_instance = Pointer;


// The creation structure that is used when you are creating a finder
type
  PNDIlib_find_create = ^TNDIlib_find_create;
  TNDIlib_find_create = packed record
    // Do we want to incluide the list of NDI sources that are running
    // on the local machine ?
    // If TRUE then local sources will be visible, if FALSE then they
    // will not.
    show_local_sources: integer;

	  // Which groups do you want to search in for sources
    p_groups: PAnsiChar;
  end;


//**************************************************************************************************************************
// Create a new finder instance. This will return NULL if it fails.

function NDIlib_find_create(p_create_settings: PNDIlib_find_create): TNDIlib_find_instance;
  cdecl; external PROCESSINGNDILIB_API;

// This will destroy an existing finder instance.
procedure NDIlib_find_destroy(p_instance: TNDIlib_find_instance);
  cdecl; external PROCESSINGNDILIB_API;
// This will recover the current set of located NDI sources. The string list is
// retained as a member of the instance (so you do not need to worry about freeing it)
// and is valid until you call this function again. When the instance is destroyed
// the pointer is no longer valid either.

function NDIlib_find_get_sources(p_instance: PNDIlib_find_instance; var p_no_sources: Cardinal; const timeout_in_ms: Cardinal): PNDIlib_source;
  cdecl; external PROCESSINGNDILIB_API;
{$endif} (* PROCESSING_NDI_FIND_H *)
