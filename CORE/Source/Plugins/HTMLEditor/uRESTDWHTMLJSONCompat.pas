unit uRESTDWHTMLJSONCompat;

interface

uses
 SysUtils, Classes, uRESTDWJSON;

type
 TRESTDWJSONType = (jtUnknown, jtObject, jtArray, jtString, jtNumber, jtBoolean, jtNull);

 TJSONData = class
 private
  FValue : TZAbstractObject;
  FOwns  : Boolean;
 protected
  constructor CreateValue(AValue : TZAbstractObject; AOwns : Boolean);
 public
  destructor Destroy; override;
  function JSONType : TRESTDWJSONType;
  function AsString : String;
  function AsJSON : String;
  property Value : TZAbstractObject read FValue;
 end;

 TJSONObject = class;
 TJSONArray = class;

 TJSONObject = class(TJSONData)
 private
  function Obj : uRESTDWJSON.TJSONObject;
  function GetArrays(const AName : String) : TJSONArray;
  function GetObjects(const AName : String) : TJSONObject;
 public
  constructor Create; overload;
  constructor CreateValue(AValue : TZAbstractObject; AOwns : Boolean); reintroduce; overload;
  procedure Add(const AName, AValue : String); overload;
  procedure Add(const AName : String; AValue : Integer); overload;
  procedure Add(const AName : String; AValue : Boolean); overload;
  procedure Add(const AName : String; AValue : TJSONObject); overload;
  function Get(const AName, ADefault : String) : String; overload;
  function Get(const AName : String; ADefault : Integer) : Integer; overload;
  function Find(const AName : String) : TJSONData;
  property Arrays[const AName : String] : TJSONArray read GetArrays;
  property Objects[const AName : String] : TJSONObject read GetObjects;
 end;

 TJSONArray = class(TJSONData)
 private
  function Arr : uRESTDWJSON.TJSONArray;
  function GetCount : Integer;
  function GetObjects(AIndex : Integer) : TJSONObject;
 public
  constructor CreateValue(AValue : TZAbstractObject; AOwns : Boolean); reintroduce;
  property Count : Integer read GetCount;
  property Objects[AIndex : Integer] : TJSONObject read GetObjects;
 end;

function GetJSON(const AText : String) : TJSONData;

implementation

constructor TJSONData.CreateValue(AValue : TZAbstractObject; AOwns : Boolean);
begin
 inherited Create;
 FValue := AValue;
 FOwns := AOwns;
end;

destructor TJSONData.Destroy;
begin
 if FOwns then
  FValue.Free;
 inherited Destroy;
end;

function TJSONData.JSONType : TRESTDWJSONType;
begin
 Result := jtUnknown;
 if FValue = nil then
  Exit;
 if FValue is uRESTDWJSON.TJSONObject then
  Result := jtObject
 else if FValue is uRESTDWJSON.TJSONArray then
  Result := jtArray
 else if FValue is _String then
  Result := jtString
 else if FValue is _Number then
  Result := jtNumber
 else if FValue is _Boolean then
  Result := jtBoolean
 else if FValue is NULL then
  Result := jtNull;
end;

function TJSONData.AsString : String;
begin
 if FValue = nil then
  Result := ''
 else
  Result := FValue.ToString;
end;

function TJSONData.AsJSON : String;
begin
 if FValue = nil then
  Result := ''
 else
  Result := uRESTDWJSON.TJSONObject.ValueToString(FValue);
end;

constructor TJSONObject.Create;
begin
 inherited CreateValue(uRESTDWJSON.TJSONObject.Create, True);
end;

constructor TJSONObject.CreateValue(AValue : TZAbstractObject; AOwns : Boolean);
begin
 inherited CreateValue(AValue, AOwns);
end;

function TJSONObject.Obj : uRESTDWJSON.TJSONObject;
begin
 Result := uRESTDWJSON.TJSONObject(FValue);
end;

procedure TJSONObject.Add(const AName, AValue : String);
begin
 Obj.Put(AName, AValue);
end;

procedure TJSONObject.Add(const AName : String; AValue : Integer);
begin
 Obj.Put(AName, AValue);
end;

procedure TJSONObject.Add(const AName : String; AValue : Boolean);
begin
 Obj.Put(AName, AValue);
end;

procedure TJSONObject.Add(const AName : String; AValue : TJSONObject);
var
 LValue : TZAbstractObject;
begin
 if AValue = nil then
  Exit;
 LValue := AValue.FValue;
 AValue.FOwns := False;
 Obj.Put(AName, LValue);
end;

function TJSONObject.Get(const AName, ADefault : String) : String;
begin
 Result := Obj.OptString(AName, ADefault);
end;

function TJSONObject.Get(const AName : String; ADefault : Integer) : Integer;
begin
 Result := Obj.OptInt(AName, ADefault);
end;

function TJSONObject.Find(const AName : String) : TJSONData;
var
 V : TZAbstractObject;
begin
 Result := nil;
 V := Obj.Opt(AName);
 if V = nil then
  Exit;
 if V is uRESTDWJSON.TJSONObject then
  Result := TJSONObject.CreateValue(V, False)
 else if V is uRESTDWJSON.TJSONArray then
  Result := TJSONArray.CreateValue(V, False)
 else
  Result := TJSONData.CreateValue(V, False);
end;

function TJSONObject.GetArrays(const AName : String) : TJSONArray;
var
 V : uRESTDWJSON.TJSONArray;
begin
 Result := nil;
 V := Obj.OptJSONArray(AName);
 if V <> nil then
  Result := TJSONArray.CreateValue(V, False);
end;

function TJSONObject.GetObjects(const AName : String) : TJSONObject;
var
 V : uRESTDWJSON.TJSONObject;
begin
 Result := nil;
 V := Obj.OptJSONObject(AName);
 if V <> nil then
  Result := TJSONObject.CreateValue(V, False);
end;

constructor TJSONArray.CreateValue(AValue : TZAbstractObject; AOwns : Boolean);
begin
 inherited CreateValue(AValue, AOwns);
end;

function TJSONArray.Arr : uRESTDWJSON.TJSONArray;
begin
 Result := uRESTDWJSON.TJSONArray(FValue);
end;

function TJSONArray.GetCount : Integer;
begin
 Result := Arr.Length;
end;

function TJSONArray.GetObjects(AIndex : Integer) : TJSONObject;
var
 V : uRESTDWJSON.TJSONObject;
begin
 Result := nil;
 if (AIndex < 0) or (AIndex >= Arr.Length) then
  Exit;
 V := Arr.OptJSONObject(AIndex);
 if V <> nil then
  Result := TJSONObject.CreateValue(V, False);
end;

function GetJSON(const AText : String) : TJSONData;
var
 LTokener : JSONTokener;
 V : TZAbstractObject;
begin
 Result := nil;
 LTokener := JSONTokener.Create(AText);
 try
  V := LTokener.NextValue;
 finally
  LTokener.Free;
 end;
 if V = nil then
  Exit;
 if V is uRESTDWJSON.TJSONObject then
  Result := uRESTDWHTMLJSONCompat.TJSONObject.CreateValue(V, True)
 else if V is uRESTDWJSON.TJSONArray then
  Result := uRESTDWHTMLJSONCompat.TJSONArray.CreateValue(V, True)
 else
  Result := TJSONData.CreateValue(V, True);
end;

end.
