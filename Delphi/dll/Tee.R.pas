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

implementation

uses
  Windows;

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
      @RAW := GetProcAddress(R_DllHandle, 'RAW');
      R_NilValue := GetProcAddress(R_DllHandle, 'R_NilValue');
    end;
  end;

  Result := (R_DllHandle <> 0) and Assigned(Rf_allocVector);
end;

end.
