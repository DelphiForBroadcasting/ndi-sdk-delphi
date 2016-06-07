program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  System.Types,
  Processing.NDI.Lib in '..\..\..\include\Processing.NDI.Lib.pas';


// We are going to create an NDI finder that locates sources on the network.
// including ones that are available on this machine itself. It will use the default
// groups assigned for the current machine.
//const

var
  pNDI_find   : TNDIlib_find_instance;
  p_sources   : PNDIlib_source;
  no_sources  : Cardinal;
  i           : integer;
  start       : cardinal;

  NDI_find_create_desc : TNDIlib_find_create;
begin
  try
    // Not required, but "correct" (see the SDK documentation.

    if (NDIlib_initialize() = 0) then
    begin
      // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
      // you can check this directly with a call to NDIlib_is_supported_CPU()
      writeln('Cannot run NDI.');
      exit;
    end;

    writeln(format('NDI Lib Version is %s', [NDIlib_version]));


    NDI_find_create_desc.show_local_sources := 1;
    NDI_find_create_desc.p_groups := '';
    pNDI_find := nil;
    // We create the NDI finder
    pNDI_find := NDIlib_find_create(@NDI_find_create_desc);
    if not assigned(pNDI_find) then
      exit;

    // Run for one minute
    start := GetTickCount();
    while (GetTickCount() - start) < 10000 do
    begin

    	// Wait up till 10 seconds to check for new sources having been added or removed from the network.
      // Because we have specified a non zero timeout here, this will return NULL if there have been no changes.
      no_sources := 0;
      p_sources := NDIlib_find_get_sources(pNDI_find, no_sources, 1000);

      // If it returned NULL then where where no changes on the network. If we have specified a timeout of 0,
      // then it always returns all sources on the network.
      if not assigned(p_sources) then
        continue;

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
