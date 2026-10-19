{*********************************************}
{  TeeChart for R                             }
{  Copyright (c) 2026 by Steema Software      }
{  All Rights Reserved                        }
{*********************************************}
library teechart;

uses
  TeeProcs,
  TeEngine,
  Chart,
  Series,

  TeeExport,
  TeePNG,
  TeeJPEG,

  TeeTools,

  Math,
  System.SysUtils,
  System.Classes,
  VCL.Controls,
  VCL.Forms,

  TeeChart_GDIPlus in 'TeeChart_GDIPlus.pas',
  Tee.R in 'Tee.R.pas';

{$R *.res}

function CreateImage(const APanel:TCustomTeePanel; const AFormat:TTeeExportFormatClass):SEXP;
var memStream : TMemoryStream;
    pngResult: SEXP;
    rawPtr: PByte;
begin
  memStream := TMemoryStream.Create;
  try
    with AFormat.Create do
    try
      Panel:=APanel;

      SaveToStream(memStream);

      pngResult := Rf_allocVector(RAWSXP, memStream.Size);

      rawPtr := RAW(pngResult);
      memStream.Position := 0;
      memStream.Read(rawPtr^, memStream.Size);

      Result := pngResult;
    finally
      Free;
    end;

  finally
    memStream.Free;
  end;
end;

function CreateChart(const X,Y:TDoubleArray; const Texts:TStringArray; AWidth:Integer=0; AHeight:Integer=0):TChart;
var t, nY, nX, nTexts : Integer;
    tmp : TChartSeries;
begin
  result:=TChart.Create(nil);

  result.View3D:=False;

  if AWidth<>0 then
     result.Width:=AWidth;

  if AHeight<>0 then
     result.Height:=AHeight;

  nY:=Length(Y);
  nX:=Length(X);

  if nY>0 then
  begin
    if nX>0 then
    begin
      tmp:=TPointSeries.Create(result);
      tmp.XValues.Order:=loNone;
      result.Axes.Bottom.Texts.Style:=talValue;
    end
    else
    if nY>200 then
       tmp:=TFastLineSeries.Create(result)
    else
    if nY>25 then
       tmp:=TLineSeries.Create(result)
    else
    begin
      tmp:=TBarSeries.Create(result);
      tmp.Marks.Style:=smsValue;
      tmp.ColorEachPoint:=True;
    end;

    result.AddSeries(tmp);

    nTexts:=Length(Texts);

    for t:=0 to nY-1 do
    begin
      if nX>t then
         tmp.AddXY(X[t],Y[t])
      else
         tmp.Add(Y[t]);

      if nTexts>t then
         tmp.XLabel[t]:=Texts[t];

    end;
  end;

  result.Tools.Add(TMarksTipTool.Create(result));
end;

procedure ShowForm(const AChart:TChart);
var tmp : TForm;
begin
  tmp:=TForm.Create(nil);
  try
    tmp.Caption:='TeeChart for R - www.steema.com';

    AChart.Align:=alClient;
    AChart.Parent:=tmp;
    tmp.ShowModal;
  finally
    tmp.Free;
  end;
end;

function RealsFrom(n: PInteger; data: PDouble): TDoubleArray;
begin
  SetLength(Result, n^);

  if n^ > 0 then
     Move(data^, Result[0], n^ * SizeOf(Double));
end;

function TextsFrom(n: PInteger; data: PPAnsiChar): TStringArray;
var
  t: Integer;
  p: PAnsiChar;
begin
  SetLength(Result, n^);
  for t := 0 to n^ - 1 do
  begin
    p := PPAnsiChar(PByte(data) + t * SizeOf(Pointer))^;   // data[t]
    if p = nil then
      Result[t] := ''
    else
      Result[t] := UTF8ToString(RawByteString(p));
  end;
end;

function StringFrom(data: PPAnsiChar): string;
begin
  if (data = nil) or (data^ = nil) then
    Result := ''
  else
    Result := UTF8ToString(RawByteString(data^));
end;

function TeeChartRender(nx_ptr:PInteger; x_ptr:PDouble;
                        ny_ptr:PInteger; y_ptr:PDouble;
                        ntexts_ptr:PInteger; texts_ptr:PPAnsiChar;
                        output_type_ptr:PPAnsiChar;
                        width_ptr, height_ptr: SEXP;
                        title_ptr, footer_ptr:PPAnsiChar
                        ): SEXP; stdcall; export;
var
  outputTypeStr: string;
  tmpChart : TChart;
  width, height : Integer;
begin
  if not InitRAPI then
     raise Exception.Create('Error. Cannot locate and initialize R.dll');

  SetExceptionMask(exAllArithmeticExceptions);

  width := PInteger(width_ptr)^;
  height := PInteger(height_ptr)^;

  tmpChart:=CreateChart(RealsFrom(nx_ptr,x_ptr),
                        RealsFrom(ny_ptr,y_ptr),
                        TextsFrom(ntexts_ptr,texts_ptr),
                        Width,Height);
  try
    outputTypeStr := StringFrom(output_type_ptr);

    tmpChart.Title.Text.Text := StringFrom(title_ptr);
    tmpChart.Foot.Text.Text := StringFrom(footer_ptr);

    if SameText(outputTypeStr,'png') then
       result:=CreateImage(tmpChart,TPNGExportFormat)
    else
    if SameText(outputTypeStr,'jpeg') or SameText(outputTypeStr,'jpg') then
       result:=CreateImage(tmpChart,TJPEGExportFormat)
    else
    begin
      ShowForm(tmpChart);
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
  TeeChartRender,
  R_init_teechart;

end.
