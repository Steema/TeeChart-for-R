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

function Rf_length(x: SEXP): Integer; stdcall; external 'R.dll';
function REAL(x: SEXP): PDoubleArray; stdcall; external 'R.dll';

function Rf_allocVector(stype: SEXPTYPE; n: Integer): Pointer; stdcall; external 'R.dll';
function RAW(x: SEXP): PByte; stdcall; external 'R.dll';
function STRING_ELT(x: SEXP; i: Integer): SEXP; stdcall; external 'R.dll';
function R_CHAR(x: SEXP): PAnsiChar; stdcall; external 'R.dll';

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

var
  R_NilValue: Pointer = nil;

procedure InitRNilValue;
var
  hR: HMODULE;
  p: ^Pointer;
begin
  if R_NilValue = nil then
  begin
    hR := GetModuleHandle('R.dll');
    if hR <> 0 then
    begin
      p := GetProcAddress(hR, 'R_NilValue');
      if p <> nil then
        R_NilValue := p^;
    end;
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

function TeeChartRender(nx_ptr, x_ptr,
                        ny_ptr, y_ptr,
                        ntexts_ptr, texts_ptr,
                        output_type_ptr,
                        width_ptr, height_ptr: SEXP): SEXP; stdcall;
var
  outputTypeStr: string;
  cStr: PAnsiChar;
  tmpChart : TChart;
  width, height : Integer;
begin
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

begin
  InitRNilValue;
end.
