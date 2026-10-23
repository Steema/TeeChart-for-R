{*********************************************}
{  TeeChart for R                             }
{  Copyright (c) 2026 by Steema Software      }
{  All Rights Reserved                        }
{*********************************************}
unit Tee.R;

interface

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
  TRAW = function(x: SEXP): PByte; stdcall;

var
  Rf_allocVector: TRf_allocVector = nil;
  Rf_length: TRf_length = nil;
  R_CHAR: TR_CHAR = nil;
  RAW : TRAW = nil;
  R_NilValue : Pointer = nil;

function InitRAPI: Boolean;

function BoolFrom(n: PInteger): Boolean; inline;
function RealsFrom(n: PInteger; data: PDouble): TDoubleArray;
function StringFrom(data: PPAnsiChar): string;
function TextsFrom(n: PInteger; data: PPAnsiChar): TStringArray;

implementation

uses
  {$IFDEF MSWINDOWS}
  Windows
  {$ELSE}
  Posix.Dlfcn
  {$ENDIF}
  ;

function BoolFrom(n: PInteger): Boolean; inline;
begin
  result:=n^ <> 0;
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

{$IFNDEF MSWINDOWS}
function GetModuleHandle(const Lib:MarshaledAString):HMODULE;
begin
  result:=dlopen(Lib,RTLD_LAZY);
end;

function GetProcAddress(const Lib:HMODULE; const Name:MarshaledAString):Pointer;
begin
  result:=dlsym(Lib,Name);
end;
{$ENDIF}

const
  RLib = {$IFDEF MSWINDOWS}'R.dll'{$ELSE}'libR.so'{$ENDIF};

var
  R_DllHandle: HMODULE = 0;

function InitRAPI: Boolean;
begin
  if R_DllHandle = 0 then
  begin
    R_DllHandle := GetModuleHandle(RLib);

    {$IFDEF MSWINDOWS}
    if R_DllHandle = 0 then
       R_DllHandle := LoadLibrary(RLib);
    {$ENDIF}

    if R_DllHandle <> 0 then
    begin
      @Rf_allocVector := GetProcAddress(R_DllHandle, 'Rf_allocVector');
      @Rf_length := GetProcAddress(R_DllHandle, 'Rf_length');
      @R_CHAR := GetProcAddress(R_DllHandle,'R_CHAR');
      @RAW := GetProcAddress(R_DllHandle, 'RAW');
      R_NilValue := GetProcAddress(R_DllHandle, 'R_NilValue');
    end;
  end;

  Result := (R_DllHandle <> 0) and Assigned(Rf_allocVector);
end;

end.
