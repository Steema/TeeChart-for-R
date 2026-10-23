{*********************************************}
{  TeeChart for R                             }
{  Copyright (c) 2026 by Steema Software      }
{  All Rights Reserved                        }
{*********************************************}
library teechart;

{$IFDEF LINUX}
{$LIBPREFIX ''}  // teechart.so Linux
{$ENDIF}

{$IFNDEF MSWINDOWS}
{$DEFINE FMX}
{$ENDIF}

uses
  {$IFDEF FMX}
  FMXTee.Chart,
  FMX.Platform,
  {$ELSE}
  VCLTee.Chart,
  {$ENDIF }
  Math,
  System.SysUtils,
  System.Classes,
  Tee.R in 'Tee.R.pas',
  Tee.Styles in 'Tee.Styles.pas',
  Tee.RChart in 'Tee.RChart.pas';

{$R *.res}

procedure TeeChartGetBytes(buf: PByte; n: PInteger); cdecl;
begin
  if (n^ > 0) and (n^ <= Length(GBytes)) then
      Move(GBytes[0], buf^, n^);
end;

function TeeChartRender(nx_ptr:PInteger; x_ptr:PDouble;
                        ny_ptr:PInteger; y_ptr:PDouble;
                        nz_ptr:PInteger; z_ptr:PDouble;
                        ntexts_ptr:PInteger; texts_ptr:PPAnsiChar;
                        output_type_ptr:PPAnsiChar;
                        width_ptr, height_ptr: SEXP;
                        style_ptr, title_ptr, footer_ptr:PPAnsiChar;
                        isHoriz_ptr,
                        commander_ptr,
                        opengl_ptr,
                        bufSize :PInteger
                        ): SEXP; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; export;
var
  outputTypeStr: string;
  tmpChart : TChart;
begin
  if not InitRAPI then
     raise Exception.Create('Error. Cannot locate and initialize R.dll');

  SetExceptionMask(exAllArithmeticExceptions);

  tmpChart:=CreateChart(RealsFrom(nx_ptr,x_ptr),
                        RealsFrom(ny_ptr,y_ptr),
                        RealsFrom(nz_ptr,z_ptr),
                        TextsFrom(ntexts_ptr,texts_ptr),
                        StyleFrom(Trim(StringFrom(style_ptr))),
                        BoolFrom(isHoriz_ptr),
                        PInteger(width_ptr)^,
                        PInteger(height_ptr)^,
                        StringFrom(title_ptr),
                        StringFrom(footer_ptr),
                        BoolFrom(opengl_ptr)
                        );
  try
    outputTypeStr := StringFrom(output_type_ptr);

    {$IFNDEF FMX} // TODO
    if SameText(outputTypeStr,'png') then
       result:=CreateImage(tmpChart,TPNGExportFormat,bufSize^)
    else
    if SameText(outputTypeStr,'jpeg') or SameText(outputTypeStr,'jpg') then
       result:=CreateImage(tmpChart,TJPEGExportFormat,bufSize^)
    else
    {$ENDIF}
    begin
      ShowForm(tmpChart,BoolFrom(commander_Ptr),SameText(outputTypeStr,'window'));

      tmpChart:=nil; // <-- already freed above
      result := R_NilValue;
    end;

  finally
    tmpChart.Free;
  end;
end;

procedure R_init_teechart(DllInfo: Pointer); cdecl; export;
begin
end;

exports
  TeeChartRender name 'TeeChartRender',
  TeeChartGetBytes name 'TeeChartGetBytes',
  R_init_teechart name 'R_init_teechart';

end.
