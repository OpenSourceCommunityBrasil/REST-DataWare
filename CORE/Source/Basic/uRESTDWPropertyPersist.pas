unit uRESTDWPropertyPersist;

{$I ..\Includes\uRESTDW.inc}

interface

uses
  Classes;

 Type
  TRESTDWPropertyPersist = Class(TComponent, IStreamPersist)
  Public
   Procedure LoadFromStream(Stream       : TStream);
   Procedure SaveToStream  (Stream       : TStream);
   Procedure SaveToFile  (Const FileName : String);
   Procedure LoadFromFile(Const FileName : String);
 End;

Implementation

uses
  TypInfo, Sysutils;

Procedure TRESTDWPropertyPersist.LoadFromFile(Const FileName : String);
Var
 Stream : TStream;
Begin
 Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 Try
  LoadFromStream(Stream);
 Finally
  Stream.Free;
 End;
End;

Procedure TRESTDWPropertyPersist.LoadFromStream(Stream : TStream);
Var
 Reader    : TReader;
 PropName,
 PropValue : String;
Begin
 Reader := TReader.Create(Stream, $FFF);
 Stream.Position := 0;
 Reader.ReadListBegin;
 While Not Reader.EndOfList Do
  Begin
   PropName  := Reader.ReadString;
   PropValue := Reader.ReadString;
   SetPropValue(Self, PropName, PropValue);
  End;
 FreeAndNil(Reader);
End;

Procedure TRESTDWPropertyPersist.SaveToFile(Const FileName : String);
Var
 Stream : TStream;
Begin
 Stream := TFileStream.Create(FileName, fmCreate);
 Try
  SaveToStream(Stream);
 Finally
  Stream.Free;
 End;
End;

Procedure TRESTDWPropertyPersist.SaveToStream(Stream : TStream);
Var
 PropName,
 PropValue   : String;
 lPropInfo   : PPropInfo;
 cnt,
 lPropCount  : Integer;
 lPropList   : PPropList;
 {$IFDEF RESTDWLAZARUS}
   lPropType : PTypeInfo;
 {$ELSE}
   lPropType : PPTypeInfo;
 {$ENDIF}
 Writer      : TWriter;
Begin
 lPropCount  := GetPropList   (PTypeInfo(ClassInfo), lPropList);
 Writer      := TWriter.Create(Stream, $FFF);
 Stream.Size := 0;
 Writer.WriteListBegin;
 For cnt := 0 To lPropCount - 1 Do
  Begin
   lPropInfo := lPropList^[cnt];
   lPropType := lPropInfo^.PropType;
   If lPropInfo^.SetProc = Nil      Then Continue;
   If lPropType^.Kind    = tkMethod Then Continue;
   PropName  := lPropInfo^.Name;
   PropValue := GetPropValue(Self, PropName);
   Writer.WriteString(PropName);
   Writer.WriteString(PropValue);
  End;
 Writer.WriteListEnd;
 FreeAndNil(Writer);
End;

End.
