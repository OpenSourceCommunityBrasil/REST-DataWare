Unit uRESTDWFCMJSON;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMMessage,
  uRESTDWFCMValue;

Function RESTDWFCMMessageToJSON(Const ADeviceToken : String;
                                AMessage           : TRESTDWFCMMessage) : String;

Function RESTDWFCMMessageToJSONTarget(Const ATargetName,
                                            ATargetValue : String;
                                      AMessage           : TRESTDWFCMMessage;
                                      AValidateOnly      : Boolean) : String;

Procedure RESTDWFCMJSONToMessage(Const AJSON : String;
                                 AMessage    : TRESTDWFCMMessage);

Procedure RESTDWFCMJSONToData(Const AJSON : String;
                              AData         : TStrings);

Implementation

Uses
  uRESTDWFCMCompat;

Function JSONEscape(Const AValue : String) : String;
Const
  CHex : String = '0123456789ABCDEF';
Var
  I : Integer;
  C : Char;
Begin
  Result := '';

  For I := 1 To Length(AValue) Do
  Begin
    C := AValue[I];

    Case C Of
      '"' :
        Result := Result + '\"';

      '\' :
        Result := Result + '\\';

      #8 :
        Result := Result + '\b';

      #9 :
        Result := Result + '\t';

      #10 :
        Result := Result + '\n';

      #12 :
        Result := Result + '\f';

      #13 :
        Result := Result + '\r';
    Else
      Begin
        If Ord(C) < 32 Then
          Result :=
            Result +
            '\u00' +
            CHex[(Ord(C) Shr 4) + 1] +
            CHex[(Ord(C) And $0F) + 1]
        Else
          Result := Result + C;
      End;
    End;
  End;
End;

Function JSONHexValue(AChar : Char) : Integer;
Begin
  If (AChar >= '0') And
     (AChar <= '9') Then
    Result := Ord(AChar) - Ord('0')
  Else
  If (AChar >= 'A') And
     (AChar <= 'F') Then
    Result := Ord(AChar) - Ord('A') + 10
  Else
  If (AChar >= 'a') And
     (AChar <= 'f') Then
    Result := Ord(AChar) - Ord('a') + 10
  Else
    Result := -1;
End;

Function JSONCodePointToString(ACodePoint : Cardinal) : String;
Var
  LBytes : TRESTDWFCMBytes;
Begin
  If ACodePoint <= $7F Then
  Begin
    SetLength(LBytes, 1);
    LBytes[0] := Byte(ACodePoint);
  End
  Else
  If ACodePoint <= $7FF Then
  Begin
    SetLength(LBytes, 2);
    LBytes[0] := Byte($C0 Or (ACodePoint Shr 6));
    LBytes[1] := Byte($80 Or (ACodePoint And $3F));
  End
  Else
  If ACodePoint <= $FFFF Then
  Begin
    SetLength(LBytes, 3);
    LBytes[0] := Byte($E0 Or (ACodePoint Shr 12));
    LBytes[1] := Byte($80 Or ((ACodePoint Shr 6) And $3F));
    LBytes[2] := Byte($80 Or (ACodePoint And $3F));
  End
  Else
  Begin
    If ACodePoint > $10FFFF Then
      ACodePoint := $FFFD;

    SetLength(LBytes, 4);
    LBytes[0] := Byte($F0 Or (ACodePoint Shr 18));
    LBytes[1] := Byte($80 Or ((ACodePoint Shr 12) And $3F));
    LBytes[2] := Byte($80 Or ((ACodePoint Shr 6) And $3F));
    LBytes[3] := Byte($80 Or (ACodePoint And $3F));
  End;

  Result := RESTDWFCMBytesToString(LBytes);
End;

Function JSONReadHex4(Const AValue : String;
                      APosition    : Integer;
                      Var ACode    : Cardinal) : Boolean;
Var
  I,
  LHex : Integer;
Begin
  Result := False;
  ACode := 0;

  If APosition + 3 > Length(AValue) Then
    Exit;

  For I := 0 To 3 Do
  Begin
    LHex := JSONHexValue(AValue[APosition + I]);

    If LHex < 0 Then
      Exit;

    ACode := (ACode Shl 4) Or Cardinal(LHex);
  End;

  Result := True;
End;

Function JSONUnescape(Const AValue : String) : String;
Var
  I : Integer;
  C : Char;
  LCode,
  LLow,
  LCodePoint : Cardinal;
Begin
  Result := '';
  I := 1;

  While I <= Length(AValue) Do
  Begin
    If (AValue[I] = '\') And
       (I < Length(AValue)) Then
    Begin
      Inc(I);
      C := AValue[I];

      Case C Of
        '"' : Result := Result + '"';
        '\' : Result := Result + '\';
        '/' : Result := Result + '/';
        'b' : Result := Result + #8;
        'f' : Result := Result + #12;
        'n' : Result := Result + #10;
        'r' : Result := Result + #13;
        't' : Result := Result + #9;

        'u':
          Begin
            If JSONReadHex4(AValue, I + 1, LCode) Then
            Begin
              Inc(I, 4);

              If (LCode >= $D800) And
                 (LCode <= $DBFF) And
                 (I + 6 <= Length(AValue)) And
                 (AValue[I + 1] = '\') And
                 (AValue[I + 2] = 'u') And
                 JSONReadHex4(AValue, I + 3, LLow) And
                 (LLow >= $DC00) And
                 (LLow <= $DFFF) Then
              Begin
                LCodePoint :=
                  $10000 +
                  ((LCode - $D800) Shl 10) +
                  (LLow - $DC00);

                Inc(I, 6);
                Result := Result + JSONCodePointToString(LCodePoint);
              End
              Else
                Result := Result + JSONCodePointToString(LCode);
            End
            Else
              Result := Result + '\u';
          End;
      Else
        Result := Result + C;
      End;
    End
    Else
      Result := Result + AValue[I];

    Inc(I);
  End;
End;

Procedure AddComma(Var AJSON : String;
                   Var AFirst : Boolean);
Begin
  If Not AFirst Then
    AJSON := AJSON + ',';

  AFirst := False;
End;

Procedure AddString(Var AJSON : String;
                    Var AFirst : Boolean;
                    Const AName,
                          AValue : String);
Begin
  If AValue = '' Then
    Exit;

  AddComma(AJSON, AFirst);

  AJSON :=
    AJSON +
    '"' + AName + '":"' +
    JSONEscape(AValue) +
    '"';
End;

Procedure AddBoolean(Var AJSON : String;
                     Var AFirst : Boolean;
                     Const AName : String;
                     AValue : Boolean);
Begin
  If Not AValue Then
    Exit;

  AddComma(AJSON, AFirst);

  AJSON :=
    AJSON +
    '"' + AName + '":true';
End;

Procedure AddInteger(Var AJSON : String;
                     Var AFirst : Boolean;
                     Const AName : String;
                     AValue,
                     AMinimum : Integer);
Begin
  If AValue < AMinimum Then
    Exit;

  AddComma(AJSON, AFirst);

  AJSON :=
    AJSON +
    '"' + AName + '":' +
    IntToStr(AValue);
End;

Procedure AddNumberText(Var AJSON : String;
                        Var AFirst : Boolean;
                        Const AName,
                              AValue : String);
Begin
  If AValue = '' Then
    Exit;

  AddComma(AJSON, AFirst);

  AJSON :=
    AJSON +
    '"' + AName + '":' +
    AValue;
End;

Function StringListObject(AList : TStrings) : String;
Var
  I      : Integer;
  LFirst : Boolean;
Begin
  Result := '{';
  LFirst := True;

  For I := 0 To AList.Count - 1 Do
    If AList.Names[I] <> '' Then
      AddString(
        Result,
        LFirst,
        AList.Names[I],
        AList.ValueFromIndex[I]
      );

  Result := Result + '}';
End;

Function StringListArray(AList : TStrings) : String;
Var
  I : Integer;
Begin
  Result := '[';

  For I := 0 To AList.Count - 1 Do
  Begin
    If I > 0 Then
      Result := Result + ',';

    Result :=
      Result +
      '"' +
      JSONEscape(AList[I]) +
      '"';
  End;

  Result := Result + ']';
End;

Function HexDigit(AChar : Char) : Integer;
Begin
  AChar := UpCase(AChar);

  If (AChar >= '0') And
     (AChar <= '9') Then
    Result := Ord(AChar) - Ord('0')
  Else
  If (AChar >= 'A') And
     (AChar <= 'F') Then
    Result := Ord(AChar) - Ord('A') + 10
  Else
    Result := 0;
End;

Function HexByte(Const AValue : String;
                 APosition    : Integer) : Integer;
Begin
  Result :=
    (HexDigit(AValue[APosition]) Shl 4) Or
    HexDigit(AValue[APosition + 1]);
End;

Function ColorPartJSON(AValue : Integer) : String;
Var
  LValue : Integer;
  LText  : String;
Begin
  If AValue <= 0 Then
  Begin
    Result := '0';
    Exit;
  End;

  If AValue >= 255 Then
  Begin
    Result := '1';
    Exit;
  End;

  LValue :=
    (AValue * 1000000) Div 255;

  LText := IntToStr(LValue);

  While Length(LText) < 6 Do
    LText := '0' + LText;

  Result := '0.' + LText;

  While (Length(Result) > 1) And
        (Result[Length(Result)] = '0') Do
    Delete(
      Result,
      Length(Result),
      1
    );
End;

Function WebPushActionsJSON(Actions : TRESTDWFCMWebPushActions) : String;
Var
  I      : Integer;
  LFirst : Boolean;
  LItem  : TRESTDWFCMWebPushAction;
  LJSON  : String;
Begin
  Result := '[';

  For I := 0 To Actions.Count - 1 Do
  Begin
    LItem := Actions[I];

    If I > 0 Then
      Result := Result + ',';

    LJSON := '{';
    LFirst := True;

    AddString(
      LJSON,
      LFirst,
      'action',
      LItem.Action
    );

    AddString(
      LJSON,
      LFirst,
      'title',
      LItem.Title
    );

    AddString(
      LJSON,
      LFirst,
      'icon',
      LItem.Icon
    );

    LJSON := LJSON + '}';
    Result := Result + LJSON;
  End;

  Result := Result + ']';
End;

Function FCMValueJSON(AValue : TRESTDWFCMValue) : String;
Var
  I      : Integer;
  LFirst : Boolean;
  LItem  : TRESTDWFCMValue;
Begin
  If AValue = Nil Then
  Begin
    Result := 'null';
    Exit;
  End;

  Case AValue.Kind Of
    fvkNull:
      Result := 'null';

    fvkString:
      Result := '"' + JSONEscape(AValue.StringValue) + '"';

    fvkNumber:
      Begin
        If AValue.NumberValue = '' Then
          Result := '0'
        Else
          Result := AValue.NumberValue;
      End;

    fvkBoolean:
      Begin
        If AValue.BooleanValue Then
          Result := 'true'
        Else
          Result := 'false';
      End;

    fvkObject:
      Begin
        Result := '{';
        LFirst := True;

        For I := 0 To AValue.Count - 1 Do
        Begin
          LItem := AValue[I];

          If LItem.Name <> '' Then
          Begin
            AddComma(Result, LFirst);

            Result :=
              Result +
              '"' + JSONEscape(LItem.Name) + '":' +
              FCMValueJSON(LItem);
          End;
        End;

        Result := Result + '}';
      End;

    fvkArray:
      Begin
        Result := '[';

        For I := 0 To AValue.Count - 1 Do
        Begin
          If I > 0 Then
            Result := Result + ',';

          Result :=
            Result +
            FCMValueJSON(AValue[I]);
        End;

        Result := Result + ']';
      End;
  Else
    Result := 'null';
  End;
End;

Procedure AddFCMValueItems(Var AJSON : String;
                           Var AFirst : Boolean;
                           AObject    : TRESTDWFCMValue);
Var
  I     : Integer;
  LItem : TRESTDWFCMValue;
Begin
  If AObject = Nil Then
    Exit;

  If AObject.Kind <> fvkObject Then
    Exit;

  For I := 0 To AObject.Count - 1 Do
  Begin
    LItem := AObject[I];

    If LItem.Name <> '' Then
    Begin
      AddComma(AJSON, AFirst);

      AJSON :=
        AJSON +
        '"' + JSONEscape(LItem.Name) + '":' +
        FCMValueJSON(LItem);
    End;
  End;
End;

Function AndroidJSON(AMessage : TRESTDWFCMMessage) : String;
Var
  LFirst,
  LNotificationFirst,
  LLightFirst : Boolean;
  LNotification,
  LLight : String;
  I : Integer;
Begin
  Result := '{';
  LFirst := True;

  AddString(
    Result,
    LFirst,
    'collapse_key',
    AMessage.Android.CollapseKey
  );

  AddString(
    Result,
    LFirst,
    'priority',
    AMessage.Android.Priority
  );

  AddString(
    Result,
    LFirst,
    'ttl',
    AMessage.Android.TTL
  );

  AddString(
    Result,
    LFirst,
    'restricted_package_name',
    AMessage.Android.RestrictedPackageName
  );

  AddBoolean(
    Result,
    LFirst,
    'direct_boot_ok',
    AMessage.Android.DirectBootOK
  );

  AddBoolean(
    Result,
    LFirst,
    'bandwidth_constrained_ok',
    AMessage.Android.BandwidthConstrainedOK
  );

  AddBoolean(
    Result,
    LFirst,
    'restricted_satellite_ok',
    AMessage.Android.RestrictedSatelliteOK
  );

  If AMessage.Android.Data.Count > 0 Then
  Begin
    AddComma(Result, LFirst);

    Result :=
      Result +
      '"data":' +
      StringListObject(AMessage.Android.Data);
  End;

  LNotification := '{';
  LNotificationFirst := True;

  AddString(
    LNotification,
    LNotificationFirst,
    'title',
    AMessage.Android.Title
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'body',
    AMessage.Android.Body
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'icon',
    AMessage.Android.Icon
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'color',
    AMessage.Android.Color
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'sound',
    AMessage.Android.Sound
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'tag',
    AMessage.Android.Tag
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'click_action',
    AMessage.Android.ClickAction
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'body_loc_key',
    AMessage.Android.BodyLocKey
  );

  If AMessage.Android.BodyLocArgs.Count > 0 Then
  Begin
    AddComma(
      LNotification,
      LNotificationFirst
    );

    LNotification :=
      LNotification +
      '"body_loc_args":' +
      StringListArray(AMessage.Android.BodyLocArgs);
  End;

  AddString(
    LNotification,
    LNotificationFirst,
    'title_loc_key',
    AMessage.Android.TitleLocKey
  );

  If AMessage.Android.TitleLocArgs.Count > 0 Then
  Begin
    AddComma(
      LNotification,
      LNotificationFirst
    );

    LNotification :=
      LNotification +
      '"title_loc_args":' +
      StringListArray(AMessage.Android.TitleLocArgs);
  End;

  AddString(
    LNotification,
    LNotificationFirst,
    'channel_id',
    AMessage.Android.ChannelID
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'image',
    AMessage.Android.ImageURL
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'proxy',
    AMessage.Android.Proxy
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'ticker',
    AMessage.Android.Ticker
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'sticky',
    AMessage.Android.Sticky
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'event_time',
    AMessage.Android.EventTime
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'local_only',
    AMessage.Android.LocalOnly
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'notification_priority',
    AMessage.Android.NotificationPriority
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'default_sound',
    AMessage.Android.DefaultSound
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'default_vibrate_timings',
    AMessage.Android.DefaultVibrateTimings
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'default_light_settings',
    AMessage.Android.DefaultLightSettings
  );

  If AMessage.Android.VibrateTimings.Count > 0 Then
  Begin
    AddComma(
      LNotification,
      LNotificationFirst
    );

    LNotification :=
      LNotification +
      '"vibrate_timings":' +
      StringListArray(AMessage.Android.VibrateTimings);
  End;

  AddString(
    LNotification,
    LNotificationFirst,
    'visibility',
    AMessage.Android.Visibility
  );

  AddInteger(
    LNotification,
    LNotificationFirst,
    'notification_count',
    AMessage.Android.NotificationCount,
    0
  );

  LLight := '{';
  LLightFirst := True;

  If (Length(AMessage.Android.LightColor) = 7) And
     (AMessage.Android.LightColor[1] = '#') Then
  Begin
    AddComma(
      LLight,
      LLightFirst
    );

    LLight :=
      LLight +
      '"color":{' +
      '"red":' +
      ColorPartJSON(
        HexByte(
          AMessage.Android.LightColor,
          2
        )
      ) +
      ',"green":' +
      ColorPartJSON(
        HexByte(
          AMessage.Android.LightColor,
          4
        )
      ) +
      ',"blue":' +
      ColorPartJSON(
        HexByte(
          AMessage.Android.LightColor,
          6
        )
      ) +
      ',"alpha":1}';
  End;

  AddString(
    LLight,
    LLightFirst,
    'light_on_duration',
    AMessage.Android.LightOnDuration
  );

  AddString(
    LLight,
    LLightFirst,
    'light_off_duration',
    AMessage.Android.LightOffDuration
  );

  LLight := LLight + '}';

  If Not LLightFirst Then
  Begin
    AddComma(
      LNotification,
      LNotificationFirst
    );

    LNotification :=
      LNotification +
      '"light_settings":' +
      LLight;
  End;

  For I := 0 To AMessage.Android.Extra.Count - 1 Do
    If AMessage.Android.Extra.Names[I] <> '' Then
      AddString(
        LNotification,
        LNotificationFirst,
        AMessage.Android.Extra.Names[I],
        AMessage.Android.Extra.ValueFromIndex[I]
      );

  LNotification := LNotification + '}';

  If Not LNotificationFirst Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"notification":' +
      LNotification;
  End;

  If AMessage.Android.AnalyticsLabel <> '' Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"fcm_options":{"analytics_label":"' +
      JSONEscape(AMessage.Android.AnalyticsLabel) +
      '"}';
  End;

  Result := Result + '}';

  If LFirst Then
    Result := '';
End;

Function APNSJSON(AMessage : TRESTDWFCMMessage) : String;
Var
  LFirst,
  LPayloadFirst,
  LAPSFirst,
  LAlertFirst,
  LOptionsFirst : Boolean;
  LPayload,
  LAPS,
  LAlert,
  LOptions : String;
  I : Integer;
Begin
  Result := '{';
  LFirst := True;

  If AMessage.APNS.Headers.Count > 0 Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"headers":' +
      StringListObject(AMessage.APNS.Headers);
  End;

  LPayload := '{';
  LPayloadFirst := True;

  LAPS := '{';
  LAPSFirst := True;

  LAlert := '{';
  LAlertFirst := True;

  AddString(
    LAlert,
    LAlertFirst,
    'title',
    AMessage.APNS.Title
  );

  AddString(
    LAlert,
    LAlertFirst,
    'subtitle',
    AMessage.APNS.Subtitle
  );

  AddString(
    LAlert,
    LAlertFirst,
    'body',
    AMessage.APNS.Body
  );

  AddString(
    LAlert,
    LAlertFirst,
    'title-loc-key',
    AMessage.APNS.TitleLocKey
  );

  If AMessage.APNS.TitleLocArgs.Count > 0 Then
  Begin
    AddComma(
      LAlert,
      LAlertFirst
    );

    LAlert :=
      LAlert +
      '"title-loc-args":' +
      StringListArray(AMessage.APNS.TitleLocArgs);
  End;

  AddString(
    LAlert,
    LAlertFirst,
    'subtitle-loc-key',
    AMessage.APNS.SubtitleLocKey
  );

  If AMessage.APNS.SubtitleLocArgs.Count > 0 Then
  Begin
    AddComma(
      LAlert,
      LAlertFirst
    );

    LAlert :=
      LAlert +
      '"subtitle-loc-args":' +
      StringListArray(AMessage.APNS.SubtitleLocArgs);
  End;

  AddString(
    LAlert,
    LAlertFirst,
    'loc-key',
    AMessage.APNS.BodyLocKey
  );

  If AMessage.APNS.BodyLocArgs.Count > 0 Then
  Begin
    AddComma(
      LAlert,
      LAlertFirst
    );

    LAlert :=
      LAlert +
      '"loc-args":' +
      StringListArray(AMessage.APNS.BodyLocArgs);
  End;

  AddString(
    LAlert,
    LAlertFirst,
    'launch-image',
    AMessage.APNS.LaunchImage
  );

  LAlert := LAlert + '}';

  If Not LAlertFirst Then
  Begin
    AddComma(
      LAPS,
      LAPSFirst
    );

    LAPS :=
      LAPS +
      '"alert":' +
      LAlert;
  End;

  AddString(
    LAPS,
    LAPSFirst,
    'sound',
    AMessage.APNS.Sound
  );

  AddInteger(
    LAPS,
    LAPSFirst,
    'badge',
    AMessage.APNS.Badge,
    0
  );

  AddString(
    LAPS,
    LAPSFirst,
    'category',
    AMessage.APNS.Category
  );

  AddString(
    LAPS,
    LAPSFirst,
    'thread-id',
    AMessage.APNS.ThreadID
  );

  If AMessage.APNS.ContentAvailable Then
  Begin
    AddComma(
      LAPS,
      LAPSFirst
    );

    LAPS :=
      LAPS +
      '"content-available":1';
  End;

  If AMessage.APNS.MutableContent Then
  Begin
    AddComma(
      LAPS,
      LAPSFirst
    );

    LAPS :=
      LAPS +
      '"mutable-content":1';
  End;

  AddString(
    LAPS,
    LAPSFirst,
    'target-content-id',
    AMessage.APNS.TargetContentID
  );

  AddString(
    LAPS,
    LAPSFirst,
    'interruption-level',
    AMessage.APNS.InterruptionLevel
  );

  AddNumberText(
    LAPS,
    LAPSFirst,
    'relevance-score',
    AMessage.APNS.RelevanceScore
  );

  AddString(
    LAPS,
    LAPSFirst,
    'filter-criteria',
    AMessage.APNS.FilterCriteria
  );

  AddNumberText(
    LAPS,
    LAPSFirst,
    'stale-date',
    AMessage.APNS.StaleDate
  );

  AddNumberText(
    LAPS,
    LAPSFirst,
    'timestamp',
    AMessage.APNS.LiveActivityTimestamp
  );

  AddString(
    LAPS,
    LAPSFirst,
    'event',
    AMessage.APNS.LiveActivityEvent
  );

  AddNumberText(
    LAPS,
    LAPSFirst,
    'dismissal-date',
    AMessage.APNS.LiveActivityDismissalDate
  );

  If AMessage.APNS.ContentState.Count > 0 Then
  Begin
    AddComma(
      LAPS,
      LAPSFirst
    );

    LAPS :=
      LAPS +
      '"content-state":' +
      FCMValueJSON(
        AMessage.APNS.ContentState
      );
  End;

  AddString(
    LAPS,
    LAPSFirst,
    'attributes-type',
    AMessage.APNS.LiveActivityAttributesType
  );

  If AMessage.APNS.Attributes.Count > 0 Then
  Begin
    AddComma(
      LAPS,
      LAPSFirst
    );

    LAPS :=
      LAPS +
      '"attributes":' +
      FCMValueJSON(
        AMessage.APNS.Attributes
      );
  End;

  AddFCMValueItems(
    LAPS,
    LAPSFirst,
    AMessage.APNS.APSExtra
  );

  LAPS := LAPS + '}';

  If Not LAPSFirst Then
  Begin
    AddComma(
      LPayload,
      LPayloadFirst
    );

    LPayload :=
      LPayload +
      '"aps":' +
      LAPS;
  End;

  For I := 0 To AMessage.APNS.CustomData.Count - 1 Do
    If AMessage.APNS.CustomData.Names[I] <> '' Then
      AddString(
        LPayload,
        LPayloadFirst,
        AMessage.APNS.CustomData.Names[I],
        AMessage.APNS.CustomData.ValueFromIndex[I]
      );

  AddFCMValueItems(
    LPayload,
    LPayloadFirst,
    AMessage.APNS.PayloadExtra
  );

  LPayload := LPayload + '}';

  If Not LPayloadFirst Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"payload":' +
      LPayload;
  End;

  If AMessage.APNS.LiveActivityToken <> '' Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"live_activity_token":"' +
      JSONEscape(AMessage.APNS.LiveActivityToken) +
      '"';
  End;

  LOptions := '{';
  LOptionsFirst := True;

  AddString(
    LOptions,
    LOptionsFirst,
    'image',
    AMessage.APNS.ImageURL
  );

  AddString(
    LOptions,
    LOptionsFirst,
    'analytics_label',
    AMessage.APNS.AnalyticsLabel
  );

  LOptions := LOptions + '}';

  If Not LOptionsFirst Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"fcm_options":' +
      LOptions;
  End;

  Result := Result + '}';

  If LFirst Then
    Result := '';
End;

Function WebPushJSON(AMessage : TRESTDWFCMMessage) : String;
Var
  LFirst,
  LNotificationFirst,
  LOptionsFirst : Boolean;
  LNotification,
  LOptions : String;
  I : Integer;
Begin
  Result := '{';
  LFirst := True;

  If AMessage.WebPush.Headers.Count > 0 Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"headers":' +
      StringListObject(AMessage.WebPush.Headers);
  End;

  If AMessage.WebPush.Data.Count > 0 Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"data":' +
      StringListObject(AMessage.WebPush.Data);
  End;

  LNotification := '{';
  LNotificationFirst := True;

  AddString(
    LNotification,
    LNotificationFirst,
    'title',
    AMessage.WebPush.Title
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'body',
    AMessage.WebPush.Body
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'icon',
    AMessage.WebPush.Icon
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'image',
    AMessage.WebPush.ImageURL
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'badge',
    AMessage.WebPush.Badge
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'tag',
    AMessage.WebPush.Tag
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'lang',
    AMessage.WebPush.Language
  );

  AddString(
    LNotification,
    LNotificationFirst,
    'dir',
    AMessage.WebPush.Direction
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'renotify',
    AMessage.WebPush.Renotify
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'requireInteraction',
    AMessage.WebPush.RequireInteraction
  );

  AddBoolean(
    LNotification,
    LNotificationFirst,
    'silent',
    AMessage.WebPush.Silent
  );

  AddNumberText(
    LNotification,
    LNotificationFirst,
    'timestamp',
    AMessage.WebPush.Timestamp
  );

  If AMessage.WebPush.Vibrate.Count > 0 Then
  Begin
    AddComma(
      LNotification,
      LNotificationFirst
    );

    LNotification :=
      LNotification +
      '"vibrate":[';

    For I := 0 To AMessage.WebPush.Vibrate.Count - 1 Do
    Begin
      If I > 0 Then
        LNotification := LNotification + ',';

      LNotification :=
        LNotification +
        AMessage.WebPush.Vibrate[I];
    End;

    LNotification :=
      LNotification +
      ']';
  End;

  If AMessage.WebPush.Actions.Count > 0 Then
  Begin
    AddComma(
      LNotification,
      LNotificationFirst
    );

    LNotification :=
      LNotification +
      '"actions":' +
      WebPushActionsJSON(
        AMessage.WebPush.Actions
      );
  End;

  AddFCMValueItems(
    LNotification,
    LNotificationFirst,
    AMessage.WebPush.NotificationExtra
  );

  For I := 0 To AMessage.WebPush.Extra.Count - 1 Do
    If AMessage.WebPush.Extra.Names[I] <> '' Then
      AddString(
        LNotification,
        LNotificationFirst,
        AMessage.WebPush.Extra.Names[I],
        AMessage.WebPush.Extra.ValueFromIndex[I]
      );

  LNotification := LNotification + '}';

  If Not LNotificationFirst Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"notification":' +
      LNotification;
  End;

  LOptions := '{';
  LOptionsFirst := True;

  AddString(
    LOptions,
    LOptionsFirst,
    'link',
    AMessage.WebPush.Link
  );

  AddString(
    LOptions,
    LOptionsFirst,
    'analytics_label',
    AMessage.WebPush.AnalyticsLabel
  );

  LOptions := LOptions + '}';

  If Not LOptionsFirst Then
  Begin
    AddComma(
      Result,
      LFirst
    );

    Result :=
      Result +
      '"fcm_options":' +
      LOptions;
  End;

  Result := Result + '}';

  If LFirst Then
    Result := '';
End;

Function RESTDWFCMMessageToJSONTarget(Const ATargetName,
                                            ATargetValue : String;
                                      AMessage           : TRESTDWFCMMessage;
                                      AValidateOnly      : Boolean) : String;
Var
  LMessage,
  LNotification,
  LValue : String;
  LFirst,
  LNotificationFirst : Boolean;
Begin
  LMessage := '{';
  LFirst := True;

  AddString(
    LMessage,
    LFirst,
    ATargetName,
    ATargetValue
  );

  If AMessage.Data.Count > 0 Then
  Begin
    AddComma(
      LMessage,
      LFirst
    );

    LMessage :=
      LMessage +
      '"data":' +
      StringListObject(AMessage.Data);
  End;

  If (AMessage.Title <> '') Or
     (AMessage.Body <> '') Or
     (AMessage.ImageURL <> '') Then
  Begin
    LNotification := '{';
    LNotificationFirst := True;

    AddString(
      LNotification,
      LNotificationFirst,
      'title',
      AMessage.Title
    );

    AddString(
      LNotification,
      LNotificationFirst,
      'body',
      AMessage.Body
    );

    AddString(
      LNotification,
      LNotificationFirst,
      'image',
      AMessage.ImageURL
    );

    LNotification := LNotification + '}';

    AddComma(
      LMessage,
      LFirst
    );

    LMessage :=
      LMessage +
      '"notification":' +
      LNotification;
  End;

  LValue := AndroidJSON(AMessage);

  If LValue <> '' Then
  Begin
    AddComma(
      LMessage,
      LFirst
    );

    LMessage :=
      LMessage +
      '"android":' +
      LValue;
  End;

  LValue := APNSJSON(AMessage);

  If LValue <> '' Then
  Begin
    AddComma(
      LMessage,
      LFirst
    );

    LMessage :=
      LMessage +
      '"apns":' +
      LValue;
  End;

  LValue := WebPushJSON(AMessage);

  If LValue <> '' Then
  Begin
    AddComma(
      LMessage,
      LFirst
    );

    LMessage :=
      LMessage +
      '"webpush":' +
      LValue;
  End;

  If AMessage.AnalyticsLabel <> '' Then
  Begin
    AddComma(
      LMessage,
      LFirst
    );

    LMessage :=
      LMessage +
      '"fcm_options":{"analytics_label":"' +
      JSONEscape(AMessage.AnalyticsLabel) +
      '"}';
  End;

  LMessage := LMessage + '}';

  Result :=
    '{"message":' +
    LMessage;

  If AValidateOnly Then
    Result :=
      Result +
      ',"validate_only":true';

  Result :=
    Result +
    '}';
End;

Function RESTDWFCMMessageToJSON(Const ADeviceToken : String;
                                AMessage           : TRESTDWFCMMessage) : String;
Begin
  Result :=
    RESTDWFCMMessageToJSONTarget(
      'token',
      ADeviceToken,
      AMessage,
      False
    );
End;

Procedure RESTDWFCMJSONToData(Const AJSON : String;
                              AData         : TStrings);

  Procedure SkipSpaces(Var APos : Integer);
  Begin
    While (APos <= Length(AJSON)) And
          (AJSON[APos] <= ' ') Do
      Inc(APos);
  End;

  Function ReadJSONString(Var APos : Integer) : String;
  Var
    LStart : Integer;
    LEscaped : Boolean;
  Begin
    Result := '';

    If (APos > Length(AJSON)) Or
       (AJSON[APos] <> '"') Then
      Exit;

    Inc(APos);
    LStart := APos;
    LEscaped := False;

    While APos <= Length(AJSON) Do
    Begin
      If AJSON[APos] = '\' Then
      Begin
        LEscaped := Not LEscaped;
        Inc(APos);
        Continue;
      End;

      If (AJSON[APos] = '"') And
         Not LEscaped Then
        Break;

      LEscaped := False;
      Inc(APos);
    End;

    Result :=
      JSONUnescape(
        Copy(
          AJSON,
          LStart,
          APos - LStart
        )
      );

    If (APos <= Length(AJSON)) And
       (AJSON[APos] = '"') Then
      Inc(APos);
  End;

  Function ReadJSONValue(Var APos : Integer) : String;
  Var
    LStart,
    LObjectDepth,
    LArrayDepth : Integer;
    LInString,
    LEscaped : Boolean;
  Begin
    Result := '';
    SkipSpaces(APos);

    If APos > Length(AJSON) Then
      Exit;

    If AJSON[APos] = '"' Then
    Begin
      Result := ReadJSONString(APos);
      Exit;
    End;

    LStart := APos;
    LObjectDepth := 0;
    LArrayDepth := 0;
    LInString := False;
    LEscaped := False;

    While APos <= Length(AJSON) Do
    Begin
      If LInString Then
      Begin
        If AJSON[APos] = '\' Then
        Begin
          LEscaped := Not LEscaped;
          Inc(APos);
          Continue;
        End;

        If (AJSON[APos] = '"') And
           Not LEscaped Then
          LInString := False;

        LEscaped := False;
        Inc(APos);
        Continue;
      End;

      Case AJSON[APos] Of
        '"':
          LInString := True;

        '{':
          Inc(LObjectDepth);

        '}':
          Begin
            If LObjectDepth = 0 Then
              Break;

            Dec(LObjectDepth);
          End;

        '[':
          Inc(LArrayDepth);

        ']':
          Begin
            If LArrayDepth > 0 Then
              Dec(LArrayDepth);
          End;

        ',':
          If (LObjectDepth = 0) And
             (LArrayDepth = 0) Then
            Break;
      End;

      Inc(APos);
    End;

    Result :=
      Trim(
        Copy(
          AJSON,
          LStart,
          APos - LStart
        )
      );
  End;

Var
  I : Integer;
  LName,
  LValue : String;
Begin
  If AData = Nil Then
    Exit;

  I := 1;
  SkipSpaces(I);

  If (I > Length(AJSON)) Or
     (AJSON[I] <> '{') Then
    Exit;

  Inc(I);

  While I <= Length(AJSON) Do
  Begin
    SkipSpaces(I);

    If (I > Length(AJSON)) Or
       (AJSON[I] = '}') Then
      Break;

    LName := ReadJSONString(I);

    If LName = '' Then
      Break;

    SkipSpaces(I);

    If (I > Length(AJSON)) Or
       (AJSON[I] <> ':') Then
      Break;

    Inc(I);
    LValue := ReadJSONValue(I);

    AData.Values[LName] := LValue;

    SkipSpaces(I);

    If (I <= Length(AJSON)) And
       (AJSON[I] = ',') Then
    Begin
      Inc(I);
      Continue;
    End;

    Break;
  End;
End;

Procedure RESTDWFCMJSONToMessage(Const AJSON : String;
                                 AMessage    : TRESTDWFCMMessage);
Begin
  AMessage.Raw := AJSON;

  AMessage.Title :=
    JSONUnescape(
      RESTDWFCMJSONValue(
        AJSON,
        'title'
      )
    );

  AMessage.Body :=
    JSONUnescape(
      RESTDWFCMJSONValue(
        AJSON,
        'body'
      )
    );

  AMessage.ImageURL :=
    JSONUnescape(
      RESTDWFCMJSONValue(
        AJSON,
        'image'
      )
    );
End;

End.
