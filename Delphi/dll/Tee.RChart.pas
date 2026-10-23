{*********************************************}
{  TeeChart for R                             }
{  Copyright (c) 2026 by Steema Software      }
{  All Rights Reserved                        }
{*********************************************}
unit Tee.RChart;

interface

{$IFNDEF MSWINDOWS}
{$DEFINE FMX}
{$ENDIF}

uses
  SysUtils,

  {$IFDEF FMX}
  FMXTee.Procs,
  FMXTee.Editor.Export,
  FMXTee.Engine,
  FMXTee.Chart,
  FMXTee.Series,
  FMXTee.Series.BoxPlot,
  FMXTee.Functions.Stats,
  FMXTee.Series.Surface,

  {$ELSE}
  VCL.Controls,

  TeeProcs,
  TeEngine,
  Chart,
  Series,
  StatChar,
  TeeBoxPlot,
  TeeExport,
  TeeGLCanvas,
  TeePNG,
  TeeJPEG,
  TeeSurfa,
  TeeEditPro,
  TeeOpenGL,
  TeeGLEditor,
  TeeChart_GDIPlus,
  {$ENDIF}

  Tee.R;

function CreateChart(const X,Y,Z:TDoubleArray;
                     const Texts:TStringArray;
                     ASeries:TChartSeriesClass;
                     IsHoriz:Boolean;
                     AWidth:Integer=0; AHeight:Integer=0;
                     const ATitle:String='';
                     const AFooter:String='';
                     const IsOpenGL:Boolean=False):TChart;

function CreateImage(const APanel:TCustomTeePanel;
                     const AFormat:TTeeExportFormatClass;
                     var Size:Integer):SEXP;

procedure ShowForm(const AChart:TChart; AddCommander,NonModal:Boolean);

var
  GBytes: TBytes;

implementation

uses
  {$IFDEF FMX}
  FMX.Types, FMXTee.Tools, FMX.Forms, FMXTee.Commander, Tee.ChartForm,
  {$ELSE}
  TeeTools, VCL.Forms, TeeComma,
  {$ENDIF}

  Classes;

function CreateImage(const APanel:TCustomTeePanel; const AFormat:TTeeExportFormatClass; var Size:Integer):SEXP;
var memStream : TMemoryStream;
    //pngResult: SEXP;
    //rawPtr: PByte;
begin
  memStream := TMemoryStream.Create;
  try
    with AFormat.Create do
    try
      Panel:=APanel;

      SaveToStream(memStream);

      Size := memStream.Size;

      SetLength(GBytes, Size);

      if Size > 0 then
      begin
        memStream.Position := 0;
        memStream.ReadBuffer(GBytes[0], Size);
      end;

      {
      pngResult := Rf_allocVector(RAWSXP, memStream.Size);

      rawPtr := RAW(pngResult);
      memStream.Position := 0;
      memStream.Read(rawPtr^, memStream.Size);

      Result := pngResult;
      }

      Result := R_NilValue;
    finally
      Free;
    end;
  finally
    memStream.Free;
  end;
end;

function FixHorizontal(const AClass:TChartSeriesClass; Horiz:Boolean):TChartSeriesClass;
begin
  result:=AClass;

  if Horiz then
  begin
    if result=TLineSeries then result:=THorizLineSeries else
    if result=TBarSeries then result:=THorizBarSeries else
    if result=TAreaSeries then result:=THorizAreaSeries else
    if result=THistogramSeries then result:=THorizHistogramSeries else
    if result=TBoxSeries then result:=THorizBoxSeries else
    if result=TViolinSeries then result:=THorizViolinSeries else
    if result=TBeeSwarmSeries then result:=THorizBeeSwarmSeries;
  end
  else
  begin
    if result=THorizLineSeries then result:=TLineSeries else
    if result=THorizBarSeries then result:=TBarSeries else
    if result=THorizAreaSeries then result:=TAreaSeries else
    if result=THorizHistogramSeries then result:=THistogramSeries else
    if result=THorizBoxSeries then result:=TBoxSeries else
    if result=THorizViolinSeries then result:=TViolinSeries else
    if result=THorizBeeSwarmSeries then result:=TBeeSwarmSeries;
  end;
end;

function CreateChart(const X,Y,Z:TDoubleArray;
                     const Texts:TStringArray;
                     ASeries:TChartSeriesClass;
                     IsHoriz:Boolean;
                     AWidth:Integer=0; AHeight:Integer=0;
                     const ATitle:String='';
                     const AFooter:String='';
                     const IsOpenGL:Boolean=False):TChart;

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

  result.Title.Text.Text := ATitle;
  result.Foot.Text.Text := AFooter;

  {$IFNDEF FMX}
  if IsOpenGL then
  begin
    result.Canvas:=TGLCanvas.Create;

    result.Walls.Left.Transparent:=True;
    result.Walls.Bottom.Transparent:=True;

    result.ZoomWheel:=pmwNormal;
  end;
  {$ENDIF}
end;

procedure ShowForm(const AChart:TChart; AddCommander,NonModal:Boolean);
begin
  var tmp:={$IFDEF FMX}TChartForm{$ELSE}TForm{$ENDIF}.Create(nil);
  try
    tmp.Caption:='TeeChart for R - www.steema.com';

    AChart.Align:={$IFDEF FMX}TAlignLayout.Client{$ELSE}alClient{$ENDIF};
    AChart.Parent:=tmp;

    if AddCommander then
    begin
      var Commander:=TTeeCommander.Create(tmp);
      Commander.Align:={$IFDEF FMX}TAlignLayout.Bottom{$ELSE}alBottom{$ENDIF};
      Commander.Panel:=AChart;
      Commander.Parent:=tmp;
    end;

    if NonModal then
       tmp.Show
    else
       tmp.ShowModal;
  finally
    if not NonModal then
       tmp.Free;
  end;
end;

end.
