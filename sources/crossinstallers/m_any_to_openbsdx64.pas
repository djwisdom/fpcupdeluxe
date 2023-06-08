unit m_any_to_openbsdx64;

{
Cross compiles from any platform (with supported crossbin utils to OpenBSD AMD64
Copyright (C) 2013 Reinier Olislagers

This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Library General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at your
option) any later version with the following modification:

As a special exception, the copyright holders of this library give you
permission to link this library with independent modules to produce an
executable, regardless of the license terms of these independent modules,and
to copy and distribute the resulting executable under terms of your choice,
provided that you also meet, for each linked independent module, the terms
and conditions of the license of that module. An independent module is a
module which is not derived from or based on this library. If you modify
this library, you may extend this exception to your version of the library,
but you are not obligated to do so. If you do not wish to do so, delete this
exception statement from your version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
for more details.

You should have received a copy of the GNU Library General Public License
along with this library; if not, write to the Free Software Foundation,
Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

implementation

uses
  m_crossinstaller, m_any_to_openbsd_base;

type
  TAny_openbsdx64 = class(Tany_openbsd_base)
  public
    function GetLibs(Basepath:string):boolean;override;
    function GetBinUtils(Basepath:string):boolean;override;
    constructor Create;
    destructor Destroy; override;
  end;

{ TAny_openbsdx64 }

function TAny_openbsdx64.GetLibs(Basepath:string): boolean;
begin
  result:=inherited;
end;

function TAny_openbsdx64.GetBinUtils(Basepath:string): boolean;
begin
  result:=inherited;
end;

constructor TAny_openbsdx64.Create;
begin
  inherited Create;
  FTargetCPU:=TCPU.x86_64;
  Reset;
  ShowInfo;
end;

destructor TAny_openbsdx64.Destroy;
begin
  inherited Destroy;
end;

var
  Any_openbsdx64:TAny_openbsdx64;

initialization
  Any_openbsdx64:=TAny_openbsdx64.Create;
  RegisterCrossCompiler(Any_openbsdx64.RegisterName,Any_openbsdx64);

finalization
  Any_openbsdx64.Destroy;

end.

