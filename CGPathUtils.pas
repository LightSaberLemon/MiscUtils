{
    Copyright (C) 2026 VCC
    creation date: 17 Feb 2026 - code extracted from DynTFTCodeGen (created 07 Aug 2023)
    initial release date: 17 Feb 2026

    author: VCC
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

unit CGPathUtils;

interface

uses
  SysUtils;


function OutputDir_AbsoluteToRelative(AbsolutePath, ProjectFileName: string): string;
function OutputDir_RelativeToAbsolute(RelativePath, ProjectFileName: string): string;


implementation


function OutputDir_AbsoluteToRelative(AbsolutePath, ProjectFileName: string): string;
var
  s: string;
begin
  s := AbsolutePath;
  if s > '' then
  begin
    if s[Length(s)] <> PathDelim then
      s := s + PathDelim;
        
    Result := ExtractRelativePath(ExtractFilePath(ProjectFileName), s);    
  end
  else
    Result := PathDelim;

  if Result = '' then
    Result := PathDelim;
end;


function OutputDir_RelativeToAbsolute(RelativePath, ProjectFileName: string): string;
var
  s: string;
begin
  if ProjectFileName = '' then
  begin
    Result := '';
    Exit;
  end;

  if (Length(RelativePath) > 1) and (UpCase(RelativePath[1]) in ['A'..'Z']) and (RelativePath[2] = ':') then
  begin
    if RelativePath[Length(RelativePath)] <> PathDelim then
      RelativePath := RelativePath + PathDelim;

    Result := RelativePath; 
    Exit;  
  end;
  
  if (RelativePath = '') or (RelativePath[Length(RelativePath)] <> PathDelim) then
    RelativePath := RelativePath + PathDelim;

  if RelativePath[1] <> PathDelim then
    RelativePath := PathDelim + RelativePath;

  if RelativePath[1] <> '.' then
    RelativePath := '.' + RelativePath;

  s := ExtractFilePath(ParamStr(0));
  s := s[1]; //letter
  GetDir(Ord(UpCase(s[1])) - 65 + 1, s);   //backup
  ChDir(ExtractFilePath(ProjectFileName));   //the actual folders have to exist on disk, for this to work
  Result := ExtractFilePath(ExpandFileName(RelativePath + 'a'));
  ChDir(s); //restore
end;

end.