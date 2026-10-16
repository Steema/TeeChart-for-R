library teechart;

uses
  Windows,

  TeeProcs,
  TeEngine,
  Chart,
  Series,

  TeeExport,
  TeePNG, TeeJPEG,

  System.SysUtils,
  System.Classes,
  VCL.Controls,
  VCL.Forms;

{$R *.res}

const
  REALSXP = 14;
  STRSXP = 16;
  RAWSXP = 24;

type
  SEXPTYPE = Integer;
  SEXP= ^SEXPTYPE;

  PDoubleArray = ^TDoubleArray;
  TDoubleArray = Array of Double;

  TStringArray = Array of String;

  TRf_allocVector = function(stype: Integer; n: Integer): SEXP; stdcall;
  TRf_length = function(x: SEXP): Integer; stdcall;
  TR_CHAR = function(x: SEXP): PAnsiChar; stdcall;
  TSTRING_ELT = function(x: SEXP; i: Integer): SEXP; stdcall;
  TREAL = function(x: SEXP): PDoubleArray; stdcall;
  TRAW = function(x: SEXP): PByte; stdcall;

var
  Rf_allocVector: TRf_allocVector = nil;
  Rf_length: TRf_length = nil;
  R_CHAR: TR_CHAR = nil;
  STRING_ELT: TSTRING_ELT = nil;
  REAL : TREAL = nil;
  RAW : TRAW = nil;
  R_NilValue : Pointer = nil;

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

  if AWidth<>0 then
     result.Width:=AWidth;

  if AHeight<>0 then
     result.Height:=AHeight;

  nY:=Length(Y);
  nX:=Length(X);

  if nY>0 then
  begin
    if nX>0 then
       tmp:=TPointSeries.Create(result)
    else
    if nY>200 then
       tmp:=TFastLineSeries.Create(result)
    else
    if nY>25 then
       tmp:=TLineSeries.Create(result)
    else
       tmp:=TBarSeries.Create(result);

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

end;

procedure ShowForm(const AChart:TChart);
var tmp : TForm;
begin
  tmp:=TForm.Create(nil);
  try
    AChart.Align:=alClient;
    AChart.Parent:=tmp;
    tmp.ShowModal;
  finally
    tmp.Free;
  end;
end;

function RealsFrom(n,data:SEXP):TDoubleArray;
var t, tmp : Integer;
    c : PDoubleArray;
begin
  tmp:=PInteger(n)^;
  SetLength(result, tmp);
  c := REAL(data);

  for t:=0 to tmp-1 do
      result[t] := c^[t];
end;

function TextsFrom(n,data:SEXP):TStringArray;
var t, tmp : Integer;
    sElem: SEXP;
begin
  tmp:=PInteger(n)^;
  SetLength(result, tmp);

  for t:=0 to tmp-1 do
  begin
    sElem := STRING_ELT(data, t);
    result[t] := UTF8ToString(R_CHAR(sElem));
  end;
end;

var
  R_DllHandle: HMODULE = 0;

function InitRAPI: Boolean;
begin
  if R_DllHandle = 0 then
  begin
    R_DllHandle := GetModuleHandle('R.dll');

    if R_DllHandle = 0 then
       R_DllHandle := LoadLibrary('R.dll');

    if R_DllHandle <> 0 then
    begin
      @Rf_allocVector := GetProcAddress(R_DllHandle, 'Rf_allocVector');
      @Rf_length := GetProcAddress(R_DllHandle, 'Rf_length');
      @R_CHAR := GetProcAddress(R_DllHandle,'R_CHAR');
      @STRING_ELT := GetProcAddress(R_DllHandle, 'STRING_ELT');
      @REAL := GetProcAddress(R_DllHandle, 'REAL');
      @RAW := GetProcAddress(R_DllHandle, 'RAW');
      R_NilValue := GetProcAddress(R_DllHandle, 'R_NilValue');
    end;
  end;

  Result := (R_DllHandle <> 0) and Assigned(Rf_allocVector);
end;

function TeeChartRender(nx_ptr, x_ptr,
                        ny_ptr, y_ptr,
                        ntexts_ptr, texts_ptr,
                        output_type_ptr,
                        width_ptr, height_ptr: SEXP): SEXP; stdcall; export;
var
  outputTypeStr: string;
  cStr: PAnsiChar;
  tmpChart : TChart;
  width, height : Integer;
begin
  if not InitRAPI then
     raise Exception.Create('Error. Cannot locate and initialize R.dll');

  width := PInteger(width_ptr)^;
  height := PInteger(height_ptr)^;

  tmpChart:=CreateChart(RealsFrom(nx_ptr,x_ptr),
                        RealsFrom(ny_ptr,y_ptr),
                        TextsFrom(ntexts_ptr,texts_ptr),
                        Width,Height);
  try
    cStr := R_CHAR(STRING_ELT(output_type_ptr, 0));
    outputTypeStr := UTF8ToString(cStr);

    if SameText(outputTypeStr,'png') then
       result:=CreateImage(tmpChart,TPNGExportFormat)
    else
    if SameText(outputTypeStr,'jpeg') or SameText(outputTypeStr,'jpg') then
       result:=CreateImage(tmpChart,TJPEGExportFormat)
    else
    begin
      ShowForm(tmpChart);
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
