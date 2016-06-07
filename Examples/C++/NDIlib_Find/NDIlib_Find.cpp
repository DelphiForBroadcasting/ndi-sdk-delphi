#include "stdafx.h"
#include <Processing.NDI.Lib.h>

int _tmain(int argc, _TCHAR* argv[])
{	// Not required, but "correct" (see the SDK documentation.
	if (!NDIlib_initialize())
	{	// Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
		// you can check this directly with a call to NDIlib_is_supported_CPU()
		printf("Cannot run NDI.");
		return 0;
	}
	
	// We are going to create an NDI finder that locates sources on the network.
	// including ones that are available on this machine itself. It will use the default
	// groups assigned for the current machine.
	const NDIlib_find_create_t NDI_find_create_desc = { TRUE, NULL };

	// We create the NDI finder
	NDIlib_find_instance_t pNDI_find = NDIlib_find_create(&NDI_find_create_desc);
	if (!pNDI_find) return FALSE;

	// Run for one minute
	for (DWORD start = ::GetTickCount(); ::GetTickCount() - start < 60000;)
	{	// Wait up till 10 seconds to check for new sources having been added or removed from the network.
		// Because we have specified a non zero timeout here, this will return NULL if there have been no changes.
		DWORD no_sources = 0;
		const NDIlib_source_t* p_sources = NDIlib_find_get_sources(pNDI_find, &no_sources, 10000);

		// If it returned NULL then where where no changes on the network. If we have specified a timeout of 0,
		// then it always returns all sources on the network.
		if (!p_sources) continue;

		// Display all the sources.
		printf("Network sources (%u found).\n", no_sources);
		for (DWORD i = 0; i < no_sources; i++)
			printf("%d. %s\n", i + 1, p_sources[i].p_ndi_name);
	}

	// Destroy the NDI finder
	NDIlib_find_destroy(pNDI_find);

	// Success. We are done
	return 0;
}

