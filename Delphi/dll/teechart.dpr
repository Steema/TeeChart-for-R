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
  TeeComma,
  TeeSurfa,
  TeeEditPro,
  TeeOpenGL,
  TeeGLEditor,
  Math,
  System.SysUtils,
  System.Classes,
  VCL.Controls,
  VCL.Forms,
  TeeChart_GDIPlus in 'TeeChart_GDIPlus.pas',
  Tee.R in 'Tee.R.pas',
  Tee.Styles in 'Tee.Styles.pas';

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

function CreateChart(const X,Y,Z:TDoubleArray;
                     const Texts:TStringArray;
                     ASeries:TChartSeriesClass;
                     IsHoriz:Boolean;
                     AWidth:Integer=0; AHeight:Integer=0):TChart;

var
  nY, nX, nZ,
  nTexts : Integer;

  function GuessStyle:TChartSeriesClass;
  begin
    if nX>0 then
    begin
      if nZ>0 then
         result:=TSurfaceSeries
      else
         result:=TPointSeries
    end
    else
    if nY>200 then
       result:=TFastLineSeries
    else
    if nY>25 then
       result:=TLineSeries
    else
       result:=TBarSeries;

    result:=FixHorizontal(result,IsHoriz);
  end;

  procedure SetupSeries(const S:TChartSeries);
  begin
    if S is TCustom3DSeries then
    begin
      result.View3D:=True;
      result.Chart3DPercent:=80;

      if S is TCustom3DPaletteSeries then
      begin
        TCustom3DPaletteSeries(S).UseColorRange:=False;
        TCustom3DPaletteSeries(S).UsePalette:=True;
        TCustom3DPaletteSeries(S).PaletteStyle:=psRainbow;
      end
    end
    else
    if S is TPointSeries then
    begin
      S.XValues.Order:=loNone;
      result.Axes.Bottom.Texts.Style:=talValue;
    end
    else
    if S is TCustomBarSeries then
    begin
      S.Marks.Style:=smsValue;
      S.ColorEachPoint:=True;
    end;
  end;

  procedure AddPoints(const S:TChartSeries);
  var t, ix, iy : Integer;
  begin
    if nZ>0 then
    begin
      if S is TCustom3DGridSeries then
      begin
        TCustom3DGridSeries(S).NumXValues:=nX;
        TCustom3DGridSeries(S).NumZValues:=nY;

        TCustom3DGridSeries(S).IrregularGrid:=True; // <-- guess ??
      end;

      for ix:=0 to nX-1 do
          for iy:=0 to nY-1 do
              TCustom3DSeries(S).AddXYZ(X[ix],Z[(iY*nX)+iX],Y[iY]) // <-- Warning swap Y <--> Z
    end
    else
    for t:=0 to nY-1 do
    begin
      if nX>t then
         S.AddXY(X[t],Y[t])
      else
         S.Add(Y[t]);
    end;

    for t:=0 to nTexts-1 do
        S.XLabel[t]:=Texts[t];
  end;

var tmp : TChartSeries;
begin
  result:=TChart.Create(nil);

  result.View3D:=False;

  if AWidth<>0 then
     result.Width:=AWidth;

  if AHeight<>0 then
     result.Height:=AHeight;

  nY:=Length(Y);

  if nY>0 then
  begin
    nX:=Length(X);
    nZ:=Length(Z);
    nTexts:=Length(Texts);

    if ASeries=nil then
       ASeries:=GuessStyle;

    tmp:=ASeries.Create(result);

    SetupSeries(tmp);

    result.AddSeries(tmp);

    tmp.BeginUpdate;
    try
      AddPoints(tmp);
    finally
      tmp.EndUpdate;
    end;
  end;

  result.Tools.Add(TMarksTipTool.Create(result));
end;

procedure ShowForm(const AChart:TChart; AddCommander:Boolean);
var tmp : TForm;
    Commander : TTeeCommander;
begin
  tmp:=TForm.Create(nil);
  try
    tmp.Caption:='TeeChart for R - www.steema.com';

    AChart.Align:=alClient;
    AChart.Parent:=tmp;

    if AddCommander then
    begin
      Commander:=TTeeCommander.Create(tmp);
      Commander.Align:=alBottom;
      Commander.Panel:=AChart;
      Commander.Parent:=tmp;
    end;

    tmp.ShowModal;
  finally
    tmp.Free;
  end;
end;

function TeeChartRender(nx_ptr:PInteger; x_ptr:PDouble;
                        ny_ptr:PInteger; y_ptr:PDouble;
                        nz_ptr:PInteger; z_ptr:PDouble;
                        ntexts_ptr:PInteger; texts_ptr:PPAnsiChar;
                        output_type_ptr:PPAnsiChar;
                        width_ptr, height_ptr: SEXP;
                        style_ptr, title_ptr, footer_ptr:PPAnsiChar;
                        isHoriz_ptr, commander_ptr :PInteger
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
                        RealsFrom(nz_ptr,z_ptr),
                        TextsFrom(ntexts_ptr,texts_ptr),
                        StyleFrom(Trim(StringFrom(style_ptr))),
                        BoolFrom(isHoriz_ptr),
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
      ShowForm(tmpChart,BoolFrom(commander_Ptr));
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
