program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  System.Types,
  Processing.NDI.Lib in '..\..\include\Processing.NDI.Lib.pas';


// We are going to create an NDI finder that locates sources on the network.
// including ones that are available on this machine itself. It will use the default
// groups assigned for the current machine.
//const

var
  pNDI_find   : pNDIlib_find_instance;
  p_sources   : pNDIlib_source;
  no_sources  : Cardinal;
  i           : Integer;
  start       : Cardinal;
begin
  try
    // Not required, but "correct" (see the SDK documentation.
    if (not NDIlib_initialize()) then
    begin
      // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
      // you can check this directly with a call to NDIlib_is_supported_CPU()
      writeln('Cannot run NDI.');
      exit;
    end;

    writeln(format('NDI Lib Version is %s', [NDIlib_version]));

    // We are going to create an NDI finder that locates sources on the network.
	  pNDI_find := NDIlib_find_create_v2();
    if not assigned(pNDI_find) then
      exit;

    // Run for one minute
    start := GetTickCount();
    while (GetTickCount() - start) < 10000 do
    begin
		// Wait up till 5 seconds to check for new sources to be added or removed
		if (not NDIlib_find_wait_for_sources(pNDI_find, 5000)) then
		begin
			writeln('No change to the sources found.'); 
			continue; 
		end;
		
		// Get the updated list of sources
		no_sources := 0;
		p_sources := NDIlib_find_get_current_sources(pNDI_find, no_sources);

		// Display all the sources.
		writeln(Format('Network sources (%u found).', [no_sources]));
		for i := 0 to no_sources - 1 do
		begin
			writeln(Format('%d. %s', [i + 1, p_sources^.p_ndi_name]));
			inc(p_sources, 1)
		end;
    end;

    // Destroy the NDI finder
    NDIlib_find_destroy(pNDI_find);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
