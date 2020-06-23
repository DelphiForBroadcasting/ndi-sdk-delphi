program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.Diagnostics,
  System.TimeSpan,
  System.SysUtils,
  System.Types,
  Processing.NDI.Lib in '..\..\include\Processing.NDI.Lib.pas';


var
  pNDI_find             : pNDIlib_find_instance;
  no_sources            : cardinal;
  p_sources             : pNDIlib_source = nil;
  p_sources_d           : pNDIlib_source = nil;
  pNDI_recv             : pNDIlib_recv_instance;
  video_frame           : TNDIlib_video_frame_v2;
  audio_frame           : TNDIlib_audio_frame_v2;
  i                     : integer;
  selected_source_str   : string;
  selected_source       : cardinal;
  sw                    : TStopwatch;
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

    // Create a finder
    pNDI_find := NDIlib_find_create_v2();
    if not assigned(pNDI_find) then
      exit;

	  // Wait until there is one source
    no_sources := 0;

	  while (no_sources <= 0) do
    begin
      // Wait until the sources on the nwtork have changed
      System.Writeln('Looking for sources ...');
      NDIlib_find_wait_for_sources(pNDI_find, 1000);
      p_sources := NDIlib_find_get_current_sources(pNDI_find, no_sources);

      if no_sources >= 1 then
      begin
        p_sources_d := p_sources;
        writeln(Format('Network sources (%u found).', [no_sources]));
        for i := 0 to no_sources - 1 do
        begin
          writeln(Format('%d. %s', [i + 1, p_sources_d^.p_ndi_name]));
          inc(p_sources_d, 1)
        end;
      end;
    end;

    while True do
    begin
      System.Writeln('');
      System.Write('Select Source: ');
      System.ReadLn(selected_source_str);
      try
        selected_source:= StrToInt(selected_source_str);
        if ((selected_source >= 1) and (selected_source <= no_sources)) then
        begin
          inc(p_sources, selected_source - 1);
          break;
        end;
      except  end;


      System.Writeln('Enter incorect source noumber.');
    end;


    // We now have at least one source, so we create a receiver to look at it.
    pNDI_recv := NDIlib_recv_create_v3();
    if not assigned(pNDI_recv) then
      exit;

    // Connect to our sources
    NDIlib_recv_connect(pNDI_recv, p_sources);

    // Destroy the NDI finder. We needed to have access to the pointers to p_sources[0]
    NDIlib_find_destroy(pNDI_find);

    // Run for one minute
    sw := TStopwatch.StartNew;
    while (sw.Elapsed.TotalMilliseconds <= TTimeSpan.FromMinutes(1).TotalMilliseconds) do
    begin

      case (NDIlib_recv_capture_v2(pNDI_recv, @video_frame, @audio_frame, nil, 5000)) of
      	// No data
        TNDIlib_frame_type.NDIlib_frame_type_none:
        begin
          System.Writeln('No data received.');
        end;

        // Video data
        TNDIlib_frame_type.NDIlib_frame_type_video:
        begin
          System.Writeln(Format('Video data received (%dx%d).', [video_frame.xres, video_frame.yres]));
          NDIlib_recv_free_video_v2(pNDI_recv, @video_frame);
        end;

        // Audio data
        TNDIlib_frame_type.NDIlib_frame_type_audio:
        begin
          System.Writeln(Format('Audio data received (%d samples).', [audio_frame.no_samples]));
          NDIlib_recv_free_audio_v2(pNDI_recv, @audio_frame);
        end;
        end;
    end;

    // Destroy the receiver
    NDIlib_recv_destroy(pNDI_recv);

    // Not required, but nice
    NDIlib_destroy();

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
