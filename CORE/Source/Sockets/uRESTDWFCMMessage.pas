Unit uRESTDWFCMMessage;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMValue;

Type
  TRESTDWFCMAndroid = Class(TPersistent)
  Private
    FCollapseKey            : String;
    FPriority               : String;
    FTTL                    : String;
    FRestrictedPackageName  : String;
    FDirectBootOK           : Boolean;
    FBandwidthConstrainedOK : Boolean;
    FRestrictedSatelliteOK  : Boolean;
    FTitle                  : String;
    FBody                   : String;
    FIcon                   : String;
    FColor                  : String;
    FSound                  : String;
    FTag                    : String;
    FClickAction            : String;
    FBodyLocKey             : String;
    FBodyLocArgs            : TStringList;
    FTitleLocKey            : String;
    FTitleLocArgs           : TStringList;
    FChannelID              : String;
    FImageURL               : String;
    FProxy                  : String;
    FTicker                 : String;
    FSticky                 : Boolean;
    FEventTime              : String;
    FLocalOnly              : Boolean;
    FNotificationPriority   : String;
    FVibrateTimings         : TStringList;
    FDefaultVibrateTimings  : Boolean;
    FDefaultSound           : Boolean;
    FLightColor             : String;
    FLightOnDuration        : String;
    FLightOffDuration       : String;
    FDefaultLightSettings   : Boolean;
    FVisibility             : String;
    FNotificationCount      : Integer;
    FAnalyticsLabel         : String;
    FData                   : TStringList;
    FExtra                  : TStringList;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Assign(Source : TPersistent); Override;

    Property BodyLocArgs    : TStringList Read FBodyLocArgs;
    Property TitleLocArgs   : TStringList Read FTitleLocArgs;
    Property VibrateTimings : TStringList Read FVibrateTimings;
    Property Data           : TStringList Read FData;
    Property Extra          : TStringList Read FExtra;
  Published
    Property CollapseKey           : String Read FCollapseKey Write FCollapseKey;
    Property Priority              : String Read FPriority Write FPriority;
    Property TTL                   : String Read FTTL Write FTTL;
    Property RestrictedPackageName : String Read FRestrictedPackageName Write FRestrictedPackageName;
    Property DirectBootOK          : Boolean Read FDirectBootOK Write FDirectBootOK;
    Property BandwidthConstrainedOK: Boolean Read FBandwidthConstrainedOK Write FBandwidthConstrainedOK;
    Property RestrictedSatelliteOK : Boolean Read FRestrictedSatelliteOK Write FRestrictedSatelliteOK;

    Property Title       : String Read FTitle Write FTitle;
    Property Body        : String Read FBody Write FBody;
    Property Icon        : String Read FIcon Write FIcon;
    Property Color       : String Read FColor Write FColor;
    Property Sound       : String Read FSound Write FSound;
    Property Tag         : String Read FTag Write FTag;
    Property ClickAction : String Read FClickAction Write FClickAction;
    Property BodyLocKey  : String Read FBodyLocKey Write FBodyLocKey;
    Property TitleLocKey : String Read FTitleLocKey Write FTitleLocKey;
    Property ChannelID   : String Read FChannelID Write FChannelID;
    Property ImageURL    : String Read FImageURL Write FImageURL;
    Property Proxy       : String Read FProxy Write FProxy;
    Property Ticker      : String Read FTicker Write FTicker;
    Property Sticky      : Boolean Read FSticky Write FSticky;
    Property EventTime   : String Read FEventTime Write FEventTime;
    Property LocalOnly   : Boolean Read FLocalOnly Write FLocalOnly;

    Property NotificationPriority  : String Read FNotificationPriority Write FNotificationPriority;
    Property DefaultVibrateTimings : Boolean Read FDefaultVibrateTimings Write FDefaultVibrateTimings;
    Property DefaultSound          : Boolean Read FDefaultSound Write FDefaultSound;
    Property LightColor            : String Read FLightColor Write FLightColor;
    Property LightOnDuration       : String Read FLightOnDuration Write FLightOnDuration;
    Property LightOffDuration      : String Read FLightOffDuration Write FLightOffDuration;
    Property DefaultLightSettings  : Boolean Read FDefaultLightSettings Write FDefaultLightSettings;
    Property Visibility            : String Read FVisibility Write FVisibility;
    Property NotificationCount     : Integer Read FNotificationCount Write FNotificationCount;
    Property AnalyticsLabel        : String Read FAnalyticsLabel Write FAnalyticsLabel;
  End;

  TRESTDWFCMAPNS = Class(TPersistent)
  Private
    FHeaders          : TStringList;
    FCustomData       : TStringList;
    FAPSExtra         : TRESTDWFCMValue;
    FPayloadExtra     : TRESTDWFCMValue;
    FTitle            : String;
    FSubtitle         : String;
    FBody             : String;
    FTitleLocKey      : String;
    FTitleLocArgs     : TStringList;
    FSubtitleLocKey   : String;
    FSubtitleLocArgs  : TStringList;
    FBodyLocKey       : String;
    FBodyLocArgs      : TStringList;
    FLaunchImage      : String;
    FSound            : String;
    FBadge            : Integer;
    FCategory         : String;
    FThreadID         : String;
    FContentAvailable : Boolean;
    FMutableContent   : Boolean;
    FTargetContentID  : String;
    FInterruptionLevel: String;
    FRelevanceScore   : String;
    FFilterCriteria   : String;
    FStaleDate        : String;
    FContentState     : TRESTDWFCMValue;
    FAttributes       : TRESTDWFCMValue;
    FLiveActivityTimestamp : String;
    FLiveActivityEvent : String;
    FLiveActivityDismissalDate : String;
    FLiveActivityAttributesType : String;
    FImageURL         : String;
    FAnalyticsLabel   : String;
    FLiveActivityToken : String;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Assign(Source : TPersistent); Override;

    Property Headers         : TStringList Read FHeaders;
    Property CustomData      : TStringList Read FCustomData;
    Property APSExtra        : TRESTDWFCMValue Read FAPSExtra;
    Property PayloadExtra    : TRESTDWFCMValue Read FPayloadExtra;
    Property TitleLocArgs    : TStringList Read FTitleLocArgs;
    Property SubtitleLocArgs : TStringList Read FSubtitleLocArgs;
    Property BodyLocArgs     : TStringList Read FBodyLocArgs;
    Property ContentState   : TRESTDWFCMValue Read FContentState;
    Property Attributes     : TRESTDWFCMValue Read FAttributes;
  Published
    Property Title             : String Read FTitle Write FTitle;
    Property Subtitle          : String Read FSubtitle Write FSubtitle;
    Property Body              : String Read FBody Write FBody;
    Property TitleLocKey       : String Read FTitleLocKey Write FTitleLocKey;
    Property SubtitleLocKey    : String Read FSubtitleLocKey Write FSubtitleLocKey;
    Property BodyLocKey        : String Read FBodyLocKey Write FBodyLocKey;
    Property LaunchImage       : String Read FLaunchImage Write FLaunchImage;
    Property Sound             : String Read FSound Write FSound;
    Property Badge             : Integer Read FBadge Write FBadge;
    Property Category          : String Read FCategory Write FCategory;
    Property ThreadID          : String Read FThreadID Write FThreadID;
    Property ContentAvailable  : Boolean Read FContentAvailable Write FContentAvailable;
    Property MutableContent    : Boolean Read FMutableContent Write FMutableContent;
    Property TargetContentID   : String Read FTargetContentID Write FTargetContentID;
    Property InterruptionLevel : String Read FInterruptionLevel Write FInterruptionLevel;
    Property RelevanceScore    : String Read FRelevanceScore Write FRelevanceScore;
    Property FilterCriteria    : String Read FFilterCriteria Write FFilterCriteria;
    Property StaleDate         : String Read FStaleDate Write FStaleDate;
    Property LiveActivityTimestamp : String Read FLiveActivityTimestamp Write FLiveActivityTimestamp;
    Property LiveActivityEvent : String Read FLiveActivityEvent Write FLiveActivityEvent;
    Property LiveActivityDismissalDate : String Read FLiveActivityDismissalDate Write FLiveActivityDismissalDate;
    Property LiveActivityAttributesType : String Read FLiveActivityAttributesType Write FLiveActivityAttributesType;
    Property ImageURL          : String Read FImageURL Write FImageURL;
    Property AnalyticsLabel    : String Read FAnalyticsLabel Write FAnalyticsLabel;
    Property LiveActivityToken  : String Read FLiveActivityToken Write FLiveActivityToken;
  End;

  TRESTDWFCMWebPushAction = Class(TCollectionItem)
  Private
    FAction : String;
    FTitle  : String;
    FIcon   : String;
  Published
    Property Action : String Read FAction Write FAction;
    Property Title  : String Read FTitle Write FTitle;
    Property Icon   : String Read FIcon Write FIcon;
  End;

  TRESTDWFCMWebPushActions = Class(TCollection)
  Public
    Constructor Create;
    Function Add : TRESTDWFCMWebPushAction;
    Function GetItem(AIndex : Integer) : TRESTDWFCMWebPushAction;
    Property Items[AIndex : Integer] : TRESTDWFCMWebPushAction Read GetItem; Default;
  End;

  TRESTDWFCMWebPush = Class(TPersistent)
  Private
    FHeaders            : TStringList;
    FData               : TStringList;
    FActions            : TRESTDWFCMWebPushActions;
    FExtra              : TStringList;
    FNotificationExtra  : TRESTDWFCMValue;
    FTitle              : String;
    FBody               : String;
    FIcon               : String;
    FImageURL           : String;
    FBadge              : String;
    FTag                : String;
    FLanguage           : String;
    FDirection          : String;
    FRenotify           : Boolean;
    FRequireInteraction : Boolean;
    FSilent             : Boolean;
    FTimestamp          : String;
    FVibrate            : TStringList;
    FLink               : String;
    FAnalyticsLabel     : String;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Assign(Source : TPersistent); Override;

    Property Headers : TStringList Read FHeaders;
    Property Data    : TStringList Read FData;
    Property Actions : TRESTDWFCMWebPushActions Read FActions;
    Property Extra   : TStringList Read FExtra;
    Property NotificationExtra : TRESTDWFCMValue Read FNotificationExtra;
    Property Vibrate : TStringList Read FVibrate;
  Published
    Property Title              : String Read FTitle Write FTitle;
    Property Body               : String Read FBody Write FBody;
    Property Icon               : String Read FIcon Write FIcon;
    Property ImageURL           : String Read FImageURL Write FImageURL;
    Property Badge              : String Read FBadge Write FBadge;
    Property Tag                : String Read FTag Write FTag;
    Property Language           : String Read FLanguage Write FLanguage;
    Property Direction          : String Read FDirection Write FDirection;
    Property Renotify           : Boolean Read FRenotify Write FRenotify;
    Property RequireInteraction : Boolean Read FRequireInteraction Write FRequireInteraction;
    Property Silent             : Boolean Read FSilent Write FSilent;
    Property Timestamp          : String Read FTimestamp Write FTimestamp;
    Property Link               : String Read FLink Write FLink;
    Property AnalyticsLabel     : String Read FAnalyticsLabel Write FAnalyticsLabel;
  End;

  TRESTDWFCMMessage = Class(TPersistent)
  Private
    FTitle          : String;
    FBody           : String;
    FImageURL       : String;
    FAnalyticsLabel : String;
    FData           : TStringList;
    FAndroid        : TRESTDWFCMAndroid;
    FAPNS           : TRESTDWFCMAPNS;
    FWebPush        : TRESTDWFCMWebPush;
    FRaw            : String;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Assign(Source : TPersistent); Override;
    Function Clone : TRESTDWFCMMessage;
    Procedure Clear;

    Property Data    : TStringList Read FData;
    Property Android : TRESTDWFCMAndroid Read FAndroid;
    Property APNS    : TRESTDWFCMAPNS Read FAPNS;
    Property WebPush : TRESTDWFCMWebPush Read FWebPush;
    Property Raw     : String Read FRaw Write FRaw;
  Published
    Property Title          : String Read FTitle Write FTitle;
    Property Body           : String Read FBody Write FBody;
    Property ImageURL       : String Read FImageURL Write FImageURL;
    Property AnalyticsLabel : String Read FAnalyticsLabel Write FAnalyticsLabel;
  End;

Implementation

Constructor TRESTDWFCMAndroid.Create;
Begin
  Inherited Create;
  FNotificationCount := -1;
  FBodyLocArgs := TStringList.Create;
  FTitleLocArgs := TStringList.Create;
  FVibrateTimings := TStringList.Create;
  FData := TStringList.Create;
  FExtra := TStringList.Create;
End;

Destructor TRESTDWFCMAndroid.Destroy;
Begin
  FExtra.Free;
  FData.Free;
  FVibrateTimings.Free;
  FTitleLocArgs.Free;
  FBodyLocArgs.Free;
  Inherited Destroy;
End;

Procedure TRESTDWFCMAndroid.Assign(Source : TPersistent);
Var
  LSource : TRESTDWFCMAndroid;
Begin
  If Source Is TRESTDWFCMAndroid Then
  Begin
    LSource := TRESTDWFCMAndroid(Source);

    FCollapseKey := LSource.CollapseKey;
    FPriority := LSource.Priority;
    FTTL := LSource.TTL;
    FRestrictedPackageName := LSource.RestrictedPackageName;
    FDirectBootOK := LSource.DirectBootOK;
    FBandwidthConstrainedOK := LSource.BandwidthConstrainedOK;
    FRestrictedSatelliteOK := LSource.RestrictedSatelliteOK;

    FTitle := LSource.Title;
    FBody := LSource.Body;
    FIcon := LSource.Icon;
    FColor := LSource.Color;
    FSound := LSource.Sound;
    FTag := LSource.Tag;
    FClickAction := LSource.ClickAction;
    FBodyLocKey := LSource.BodyLocKey;
    FTitleLocKey := LSource.TitleLocKey;
    FChannelID := LSource.ChannelID;
    FImageURL := LSource.ImageURL;
    FProxy := LSource.Proxy;
    FTicker := LSource.Ticker;
    FSticky := LSource.Sticky;
    FEventTime := LSource.EventTime;
    FLocalOnly := LSource.LocalOnly;
    FNotificationPriority := LSource.NotificationPriority;
    FDefaultVibrateTimings := LSource.DefaultVibrateTimings;
    FDefaultSound := LSource.DefaultSound;
    FLightColor := LSource.LightColor;
    FLightOnDuration := LSource.LightOnDuration;
    FLightOffDuration := LSource.LightOffDuration;
    FDefaultLightSettings := LSource.DefaultLightSettings;
    FVisibility := LSource.Visibility;
    FNotificationCount := LSource.NotificationCount;
    FAnalyticsLabel := LSource.AnalyticsLabel;

    FBodyLocArgs.Assign(LSource.BodyLocArgs);
    FTitleLocArgs.Assign(LSource.TitleLocArgs);
    FVibrateTimings.Assign(LSource.VibrateTimings);
    FData.Assign(LSource.Data);
    FExtra.Assign(LSource.Extra);
  End
  Else
    Inherited Assign(Source);
End;

Constructor TRESTDWFCMAPNS.Create;
Begin
  Inherited Create;

  FBadge := -1;

  FHeaders := TStringList.Create;
  FCustomData := TStringList.Create;
  FAPSExtra := TRESTDWFCMValue.Create;
  FPayloadExtra := TRESTDWFCMValue.Create;
  FContentState := TRESTDWFCMValue.Create;
  FAttributes := TRESTDWFCMValue.Create;
  FTitleLocArgs := TStringList.Create;
  FSubtitleLocArgs := TStringList.Create;
  FBodyLocArgs := TStringList.Create;
End;

Destructor TRESTDWFCMAPNS.Destroy;
Begin
  FBodyLocArgs.Free;
  FSubtitleLocArgs.Free;
  FTitleLocArgs.Free;
  FAttributes.Free;
  FContentState.Free;
  FPayloadExtra.Free;
  FAPSExtra.Free;
  FCustomData.Free;
  FHeaders.Free;

  Inherited Destroy;
End;

Procedure TRESTDWFCMAPNS.Assign(Source : TPersistent);
Var
  LSource : TRESTDWFCMAPNS;
Begin
  If Source Is TRESTDWFCMAPNS Then
  Begin
    LSource := TRESTDWFCMAPNS(Source);

    FHeaders.Assign(LSource.Headers);
    FCustomData.Assign(LSource.CustomData);
    FAPSExtra.Assign(LSource.APSExtra);
    FPayloadExtra.Assign(LSource.PayloadExtra);
    FContentState.Assign(LSource.ContentState);
    FAttributes.Assign(LSource.Attributes);
    FTitleLocArgs.Assign(LSource.TitleLocArgs);
    FSubtitleLocArgs.Assign(LSource.SubtitleLocArgs);
    FBodyLocArgs.Assign(LSource.BodyLocArgs);

    FTitle := LSource.Title;
    FSubtitle := LSource.Subtitle;
    FBody := LSource.Body;
    FTitleLocKey := LSource.TitleLocKey;
    FSubtitleLocKey := LSource.SubtitleLocKey;
    FBodyLocKey := LSource.BodyLocKey;
    FLaunchImage := LSource.LaunchImage;
    FSound := LSource.Sound;
    FBadge := LSource.Badge;
    FCategory := LSource.Category;
    FThreadID := LSource.ThreadID;
    FContentAvailable := LSource.ContentAvailable;
    FMutableContent := LSource.MutableContent;
    FTargetContentID := LSource.TargetContentID;
    FInterruptionLevel := LSource.InterruptionLevel;
    FRelevanceScore := LSource.RelevanceScore;
    FFilterCriteria := LSource.FilterCriteria;
    FStaleDate := LSource.StaleDate;
    FLiveActivityTimestamp := LSource.LiveActivityTimestamp;
    FLiveActivityEvent := LSource.LiveActivityEvent;
    FLiveActivityDismissalDate := LSource.LiveActivityDismissalDate;
    FLiveActivityAttributesType := LSource.LiveActivityAttributesType;
    FImageURL := LSource.ImageURL;
    FAnalyticsLabel := LSource.AnalyticsLabel;
    FLiveActivityToken := LSource.LiveActivityToken;
  End
  Else
    Inherited Assign(Source);
End;

Constructor TRESTDWFCMWebPushActions.Create;
Begin
  Inherited Create(TRESTDWFCMWebPushAction);
End;

Function TRESTDWFCMWebPushActions.Add : TRESTDWFCMWebPushAction;
Begin
  Result := TRESTDWFCMWebPushAction(Inherited Add);
End;

Function TRESTDWFCMWebPushActions.GetItem(AIndex : Integer) : TRESTDWFCMWebPushAction;
Begin
  Result := TRESTDWFCMWebPushAction(Inherited Items[AIndex]);
End;

Constructor TRESTDWFCMWebPush.Create;
Begin
  Inherited Create;

  FHeaders := TStringList.Create;
  FData := TStringList.Create;
  FActions := TRESTDWFCMWebPushActions.Create;
  FExtra := TStringList.Create;
  FNotificationExtra := TRESTDWFCMValue.Create;
  FVibrate := TStringList.Create;
End;

Destructor TRESTDWFCMWebPush.Destroy;
Begin
  FVibrate.Free;
  FNotificationExtra.Free;
  FExtra.Free;
  FActions.Free;
  FData.Free;
  FHeaders.Free;

  Inherited Destroy;
End;

Procedure TRESTDWFCMWebPush.Assign(Source : TPersistent);
Var
  LSource : TRESTDWFCMWebPush;
Begin
  If Source Is TRESTDWFCMWebPush Then
  Begin
    LSource := TRESTDWFCMWebPush(Source);

    FHeaders.Assign(LSource.Headers);
    FData.Assign(LSource.Data);
    FActions.Assign(LSource.Actions);
    FExtra.Assign(LSource.Extra);
    FNotificationExtra.Assign(LSource.NotificationExtra);
    FVibrate.Assign(LSource.Vibrate);

    FTitle := LSource.Title;
    FBody := LSource.Body;
    FIcon := LSource.Icon;
    FImageURL := LSource.ImageURL;
    FBadge := LSource.Badge;
    FTag := LSource.Tag;
    FLanguage := LSource.Language;
    FDirection := LSource.Direction;
    FRenotify := LSource.Renotify;
    FRequireInteraction := LSource.RequireInteraction;
    FSilent := LSource.Silent;
    FTimestamp := LSource.Timestamp;
    FLink := LSource.Link;
    FAnalyticsLabel := LSource.AnalyticsLabel;
  End
  Else
    Inherited Assign(Source);
End;

Constructor TRESTDWFCMMessage.Create;
Begin
  Inherited Create;

  FData := TStringList.Create;
  FAndroid := TRESTDWFCMAndroid.Create;
  FAPNS := TRESTDWFCMAPNS.Create;
  FWebPush := TRESTDWFCMWebPush.Create;
End;

Destructor TRESTDWFCMMessage.Destroy;
Begin
  FWebPush.Free;
  FAPNS.Free;
  FAndroid.Free;
  FData.Free;

  Inherited Destroy;
End;

Procedure TRESTDWFCMMessage.Assign(Source : TPersistent);
Var
  LSource : TRESTDWFCMMessage;
Begin
  If Source Is TRESTDWFCMMessage Then
  Begin
    LSource := TRESTDWFCMMessage(Source);

    FTitle := LSource.Title;
    FBody := LSource.Body;
    FImageURL := LSource.ImageURL;
    FAnalyticsLabel := LSource.AnalyticsLabel;
    FRaw := LSource.Raw;

    FData.Assign(LSource.Data);
    FAndroid.Assign(LSource.Android);
    FAPNS.Assign(LSource.APNS);
    FWebPush.Assign(LSource.WebPush);
  End
  Else
    Inherited Assign(Source);
End;

Function TRESTDWFCMMessage.Clone : TRESTDWFCMMessage;
Begin
  Result := TRESTDWFCMMessage.Create;
  Result.Assign(Self);
End;

Procedure TRESTDWFCMMessage.Clear;
Var
  LEmptyAndroid : TRESTDWFCMAndroid;
  LEmptyAPNS    : TRESTDWFCMAPNS;
  LEmptyWebPush : TRESTDWFCMWebPush;
Begin
  FTitle := '';
  FBody := '';
  FImageURL := '';
  FAnalyticsLabel := '';
  FRaw := '';
  FData.Clear;

  LEmptyAndroid := TRESTDWFCMAndroid.Create;
  LEmptyAPNS := TRESTDWFCMAPNS.Create;
  LEmptyWebPush := TRESTDWFCMWebPush.Create;
  Try
    FAndroid.Assign(LEmptyAndroid);
    FAPNS.Assign(LEmptyAPNS);
    FWebPush.Assign(LEmptyWebPush);
  Finally
    LEmptyWebPush.Free;
    LEmptyAPNS.Free;
    LEmptyAndroid.Free;
  End;
End;

End.
