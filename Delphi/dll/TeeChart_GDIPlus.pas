{*********************************************}
{  TeeChart for R                             }
{  Copyright (c) 2026 by Steema Software      }
{  All Rights Reserved                        }
{*********************************************}
unit TeeChart_GDIPlus;

interface

implementation

uses
  Windows,
  GDIPAPI,
  GDIPObj;

var
  gdiplusToken: ULONG_PTR=0;
  gdiplusStartupInput: TGdiplusStartupInput;

procedure InitGDIPlus;
begin
  if gdiplusToken = 0 then
  begin
    FillChar(gdiplusStartupInput, SizeOf(gdiplusStartupInput), 0);
    gdiplusStartupInput.GdiplusVersion := 1;
    GdiplusStartup(gdiplusToken, @gdiplusStartupInput, nil);
  end;
end;

procedure ShutdownGDIPlus;
begin
  if gdiplusToken <> 0 then
  begin
    GdiplusShutdown(gdiplusToken);
    gdiplusToken := 0;
  end;
end;

initialization
  gdiplusToken := 0;
  InitGDIPlus;
finalization
  ShutdownGDIPlus;
end.
