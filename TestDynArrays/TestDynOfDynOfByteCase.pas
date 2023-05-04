{
    Copyright (C) 2023 VCC
    creation date: May 2023
    initial release date: 04 May 2023

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


unit TestDynOfDynOfByteCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,
  DynArrays, Expectations;

type

  TTestDynOfDynOfByteCase = class(TTestCase)
  published
    procedure TestSimpleAllocation;
    procedure TestWritingToArray;
    procedure TestReallocationToLargerArray;
    procedure TestReallocationToSmallerArray;
    procedure Test_AddDynArrayOfByteToDynOfDynOfByte_HappyFlow;
    procedure Test_AddDynArrayOfByteToDynOfDynOfByte_WithoutFirstInitDynArray;
    procedure Test_AddDynArrayOfByteToDynOfDynOfByte_WithoutSecondInitDynArray;
    procedure TestDoubleFree;
  end;


implementation


const
  CUninitializedDynArrayErrMsg = 'The DynArray is not initialized. Please call InitDynArrayToEmpty before working with DynArray functions.';



procedure TTestDynOfDynOfByteCase.TestSimpleAllocation;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  AllocationResult: Boolean;
  i: Integer;
begin
  InitDynOfDynOfByteToEmpty(Arr);  //this is what Delphi and FP do automatically

  AllocationResult := SetDynOfDynOfByteLength(Arr, 7);
  try
    Expect(AllocationResult).ToBe(True, 'Expected a successful allocation.');
    Expect(Byte(AllocationResult)).ToBe(Byte(True));
    Expect(Arr.Len).ToBe(7);

    for i := 0 to Arr.Len - 1 do
      CheckInitializedDynArray(Arr.Content^[i]^);    //the inner arrays are initialized automatically by SetDynOfDynOfByteLength
  finally
    FreeDynOfDynOfByteArray(Arr);  //the array has to be manually freed, because there is no reference counting
  end;
end;


procedure TTestDynOfDynOfByteCase.TestWritingToArray;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  i: Integer;
begin
  InitDynOfDynOfByteToEmpty(Arr);
  SetDynOfDynOfByteLength(Arr, 20);
  try
    for i := 0 to Arr.Len - 1 do
    begin
      SetDynLength(Arr.Content^[i]^, 3);
      Arr.Content^[i]^.Content^[2] := 80 + i;
      Expect(Arr.Content^[i]^.Content^[2]).ToBe(80 + i);
    end;
  finally
    FreeDynOfDynOfByteArray(Arr);
  end;
end;


procedure TTestDynOfDynOfByteCase.TestReallocationToLargerArray;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  i, j: Integer;
begin
  InitDynOfDynOfByteToEmpty(Arr);
  SetDynOfDynOfByteLength(Arr, 20);

  for i := 0 to DynOfDynOfByteLength(Arr) - 1 do
  begin
    SetDynLength(Arr.Content^[i]^, 3);

    for j := 0 to 2 do
      Arr.Content^[i]^.Content^[j] := i * 10 + j;
  end;

  SetDynOfDynOfByteLength(Arr, 30);
  try
    for i := 0 to 20 - 1 do  //test up to the old length, as this content has to be valid only
      for j := 0 to 2 do
        Expect(Arr.Content^[i]^.Content^[j]).ToBe(i * 10 + j, ' at i = ' + IntToStr(i) + '  j = ' + IntToStr(j));
  finally
    FreeDynOfDynOfByteArray(Arr);
  end;
end;


procedure TTestDynOfDynOfByteCase.TestReallocationToSmallerArray;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  i, j: Integer;
begin
  InitDynOfDynOfByteToEmpty(Arr);
  SetDynOfDynOfByteLength(Arr, 20);

  for i := 0 to DynOfDynOfByteLength(Arr) - 1 do
  begin
    SetDynLength(Arr.Content^[i]^, 3);

    for j := 0 to 2 do
      Arr.Content^[i]^.Content^[j] := i * 10 + j;
  end;

  SetDynOfDynOfByteLength(Arr, 10);
  try
    for i := 0 to 10 - 1 do  //test up to the old length, as this content has to be valid only
      for j := 0 to 2 do
        Expect(Arr.Content^[i]^.Content^[j]).ToBe(i * 10 + j, ' at i = ' + IntToStr(i) + '  j = ' + IntToStr(j));
  finally
    FreeDynOfDynOfByteArray(Arr);
  end;
end;


procedure TTestDynOfDynOfByteCase.Test_AddDynArrayOfByteToDynOfDynOfByte_HappyFlow;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  NewArr: TDynArrayOfByte;
  i, j: Integer;
begin
  InitDynOfDynOfByteToEmpty(Arr);
  try
    SetDynOfDynOfByteLength(Arr, 20);

    for i := 0 to DynOfDynOfByteLength(Arr) - 1 do
    begin
      SetDynLength(Arr.Content^[i]^, 3);

      for j := 0 to 2 do
        Arr.Content^[i]^.Content^[j] := i * 10 + j;
    end;

    InitDynArrayToEmpty(NewArr);
    SetDynLength(NewArr, 7);
    for j := 0 to NewArr.Len - 1 do
      NewArr.Content^[j] := 200 + j;

    try
      Expect(AddDynArrayOfByteToDynOfDynOfByte(Arr, NewArr)).ToBe(True);
    finally
      FreeDynArray(NewArr);
    end;

    for i := 0 to 20 - 1 do  //test up to the old length, as this content has to be valid only
      for j := 0 to 2 do
        Expect(Arr.Content^[i]^.Content^[j]).ToBe(i * 10 + j, ' at i = ' + IntToStr(i) + '  j = ' + IntToStr(j));

    Expect(Arr.Len).ToBe(21);
    Expect(Arr.Content^[20]^.Content).ToBe(@[200, 201, 202, 203, 204, 205, 206]);
  finally
    FreeDynOfDynOfByteArray(Arr);
  end;
end;


procedure TTestDynOfDynOfByteCase.Test_AddDynArrayOfByteToDynOfDynOfByte_WithoutFirstInitDynArray;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  NewArr: TDynArrayOfByte;
begin
  InitDynArrayToEmpty(NewArr);
  SetDynLength(NewArr, 3);

  try
    AddDynArrayOfByteToDynOfDynOfByte(Arr, NewArr);
  except
    on E: Exception do
      Expect(E.Message).ToBe(CUninitializedDynArrayErrMsg);
  end;

  FreeDynArray(NewArr);
end;


procedure TTestDynOfDynOfByteCase.Test_AddDynArrayOfByteToDynOfDynOfByte_WithoutSecondInitDynArray;
var
  Arr: TDynArrayOfTDynArrayOfByte;
  NewArr: TDynArrayOfByte;
begin
  InitDynOfDynOfByteToEmpty(Arr);
  SetDynOfDynOfByteLength(Arr, 3);

  try
    AddDynArrayOfByteToDynOfDynOfByte(Arr, NewArr);
  except
    on E: Exception do
      Expect(E.Message).ToBe(CUninitializedDynArrayErrMsg);
  end;

  FreeDynOfDynOfByteArray(Arr);
end;


procedure TTestDynOfDynOfByteCase.TestDoubleFree;
var
  Arr: TDynArrayOfTDynArrayOfByte;
begin
  InitDynOfDynOfByteToEmpty(Arr);
  SetDynOfDynOfByteLength(Arr, 3);

  FreeDynOfDynOfByteArray(Arr);
  Expect(Arr.Len).ToBe(0);
  Expect(Arr.Content).ToBe(nil);

  try                            //Free again. The structure should stay the same. No exception is expected.
    FreeDynOfDynOfByteArray(Arr);
    Expect(Arr.Len).ToBe(0);
    Expect(Arr.Content).ToBe(nil);
  except
    on E: Exception do
      Expect(E.Message).ToBe('No exception is expected!');
  end;
end;


initialization

  RegisterTest(TTestDynOfDynOfByteCase);
end.

