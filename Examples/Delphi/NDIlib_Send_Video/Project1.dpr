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
  pNDI_send             : TNDIlib_send_instance;
  NDI_send_create_desc  : TNDIlib_send_create;
  NDI_connection_type   : TNDIlib_metadata_frame;
  NDI_video_frame       : TNDIlib_video_frame;
  p_connection_string   : PAnsiChar;
  start_time            : cardinal;
  end_time              : cardinal;
  idx                   : integer;
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

    // Create an NDI source that is called "My Video" and is clocked to the video.
    NDI_send_create_desc.p_ndi_name := 'FreeHand NDI Demo';
    NDI_send_create_desc.p_groups := '';
    NDI_send_create_desc.clock_video := 1;

    // We create the NDI sender
    pNDI_send := NDIlib_send_create(@NDI_send_create_desc);
    if not assigned(pNDI_send) then
      exit;

    // Provide a meta-data registration that allows people to know what we are. Note that this is optional.
    // Note that it is possible for senders to also register their preferred video formats.
    p_connection_string := '<ndi_product long_name="NDILib Send Example." short_name="NDILib Send" manufacturer="CoolCo, inc." version="1.000.000" session="default" model_name="S1" serial="ABCDEFG"/>';


    // The length
    NDI_connection_type.length := StrLen(p_connection_string);
    // Timecode (synthesized for us !)
    NDI_connection_type.timecode := NDIlib_send_timecode_synthesize;
    // The string
    NDI_connection_type.p_data := p_connection_string;

    NDIlib_send_add_connection_metadata(pNDI_send, @NDI_connection_type);

    // We are going to create a 1920x1080 interlaced frame at 29.97Hz.
    // Resolution
    NDI_video_frame.xres := 1920;
    NDI_video_frame.yres := 1080;
    // We will stick with RGB color space. Note however that it is generally better to
    // use YCbCr colors spaces if you can since they get end-to-end better video quality
    // and better performance because there is no color dconversion
    NDI_video_frame.FourCC := NDIlib_FourCC_type_BGRA;
    // The frame-eate
    NDI_video_frame.frame_rate_N := 30000;
    NDI_video_frame.frame_rate_D := 1001;
    // The aspect ratio (16:9)
    NDI_video_frame.picture_aspect_ratio := 16.0 / 9.0;
      // This is not a progressive frame
    NDI_video_frame.is_progressive := 0;
    // Timecode (synthesized for us !)
    NDI_video_frame.timecode := NDIlib_send_timecode_synthesize;
    // The video memory used for this frame
    NDI_video_frame.p_data := AllocMem(1920 * 1080 * 4);
      // The line to line stride of this image
    NDI_video_frame.line_stride_in_bytes := 1920 * 4;

    // We will send 1000 frames of video.
    while True do
    begin
    	// Get the current time
      start_time := GetTickCount();

      // Send 200 frames
      for idx := 0 to 200 do
      begin
        FillColourBars(NDI_video_frame.p_data, 1920, 1080);
        // We now submit the frame. Note that this call will be clocked so that we end up submitting at exactly 29.97fps.
        NDIlib_send_send_video(pNDI_send, @NDI_video_frame);
      end;

      // Get the end time
      end_time := GetTickCount();

      // Just display something helpful
      writeln(Format('100 frames sent, average fps=%1.2f', [200.0 * 1000.0 / (end_time - start_time)]));
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
