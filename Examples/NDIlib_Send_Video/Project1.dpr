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

procedure FillColourBars(Buffer : PByte; Width: integer; Height: integer);
const
 gColourBars : array[0..7] of cardinal = ($ffffffff, $ffffff00, $ff00ffff, $ff00ff00, $ffff00ff, $ffff0000, $ff0000ff, $ff000000);
var
  x, y                  : integer;
  nextword              : PByte;
begin
  nextword := Buffer;
  // Fill in the buffer. It is likely that you would do something much smarter than this.
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
    begin
      pCardinal(nextword)^ := gColourBars[(x*8) div Width];
      inc(pCardinal(nextword),1);
    end;
end;

var
  pNDI_send             : pNDIlib_send_instance;
  NDI_send_create_desc  : TNDIlib_send_create;
  NDI_connection_type   : TNDIlib_metadata_frame;
  metadata_desc         : TNDIlib_metadata_frame;
  NDI_tally             : TNDIlib_tally;
  NDI_video_frame       : TNDIlib_video_frame_v2;
  idx                   : integer;
  exit_loop             : boolean;

  y,x                   : integer;
  p_image               : pByte;
  line_idx              : Integer;
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

    // Create an NDI source that is called "My Video" and is clocked to the video.
    FillChar(NDI_send_create_desc, sizeof(TNDIlib_send_create), $0);
    NDI_send_create_desc.p_groups := string.Empty;
    NDI_send_create_desc.p_ndi_name := PAnsiChar('FreeHand NDI Demo');
    NDI_send_create_desc.clock_video := True;

    // We create the NDI sender
    pNDI_send := NDIlib_send_create(@NDI_send_create_desc);
    if not assigned(pNDI_send) then
      exit;

	  // Provide a meta-data registration that allows people to know what we are. Note that this is optional.
	  // Note that it is possible for senders to also register their preferred video formats.
    FillChar(NDI_connection_type, sizeof(TNDIlib_metadata_frame), $0);
    NDI_connection_type.p_data :=  '<ndi_product long_name="NDILib Send Example." ' +
                                   '             short_name="NDILib Send" ' +
                                   '             manufacturer="CoolCo, inc." '  +
                                   '             version="1.000.000" ' +
                                   '             session="default" ' +
                                   '             model_name="S1" ' +
                                   '             serial="ABCDEFG"/>';

    NDIlib_send_add_connection_metadata(pNDI_send, @NDI_connection_type);

    // We are going to create a 1920x1080 interlaced frame at 59.94Hz.
    FillChar(NDI_video_frame, SizeOf(TNDIlib_video_frame_v2), $0);
    NDI_video_frame.xres := 1920;
    NDI_video_frame.yres := 1080;
    NDI_video_frame.FourCC := NDIlib_FourCC_type_BGRA;
    NDI_video_frame.p_data := AllocMem(NDI_video_frame.xres * NDI_video_frame.yres * 4);
    NDI_video_frame.line_stride_in_bytes := 1920 * 4;



    // We will send 1000 frames of video.
    exit_loop := false;
    idx := 0;
    while not exit_loop do
    begin

      if (NDIlib_send_get_no_connections(pNDI_send, 10000) <= 0) then
      begin	// Display status
        writeln(Format('No current connections, so no rendering needed (%d).', [idx]));
      end else
      begin
        FillChar(metadata_desc, sizeof(TNDIlib_metadata_frame), $0);
        if (NDIlib_send_capture(pNDI_send, @metadata_desc, 0) <> TNDIlib_frame_type.NDIlib_frame_type_none) then
			  begin
          // For example, this might be a connection meta-data string that might include information
          // about preferred video formats. A full XML parser should be used here, this code is for
          // illustration purposes only

          //if (strncasecmp(metadata_desc.p_data, "<ndi_format", 11))
          {	// Setup the preferred video format.
          }

          // Display that we got meta-data
          writeLn(Format('Received meta-data : %s', [metadata_desc.p_data]));

          // We must free the data here
          NDIlib_send_free_metadata(pNDI_send, @metadata_desc);
        end;


        // Get the tally state of this source (we poll it),
        FillChar(NDI_tally, sizeof(TNDIlib_tally), $0);
        NDIlib_send_get_tally(pNDI_send, @NDI_tally, 0);

        // Fill in the buffer. It is likely that you would do something much smarter than this.
        //FillColourBars(NDI_video_frame.p_data, 1920, 1080);
        for y := 0 to NDI_video_frame.yres - 1 do
        begin
            p_image := NDI_video_frame.p_data + NDI_video_frame.line_stride_in_bytes * y;
            // The index start for this line
            line_idx := y + idx;

            // Cycle over the line
            for x := 0 to NDI_video_frame.xres - 1 do
            begin
              p_image[0] := 255;
              p_image[1] := 128;
              p_image[2] := 128;
              if (line_idx and 16) > 0 then
                p_image[3] := 255 else p_image[3]:= 128;

              inc(line_idx);
              inc(pCardinal(p_image),1);
            end;
        end;


        // We now submit the frame. Note that this call will be clocked so that we end up submitting at exactly 59.94fps
			  NDIlib_send_send_video_v2(pNDI_send, @NDI_video_frame);

        // Just display something helpful
        if ((idx mod 100) = 0) then
        begin
          WriteLn(Format('Frame number %d sent. PGM:%s / PVW:%s', [1+idx, BoolTostr(NDI_tally.on_program, true), BoolToStr(NDI_tally.on_preview, true)]));
        end;

        inc(idx, 1);
      end;
    end;

    // Free the video frame
    FreeMem(NDI_video_frame.p_data);

    // Destroy the NDI sender
    NDIlib_send_destroy(pNDI_send);

    // Not required, but nice
    NDIlib_destroy();

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
