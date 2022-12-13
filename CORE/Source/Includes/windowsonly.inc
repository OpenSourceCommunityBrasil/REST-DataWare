{$IFNDEF WINDOWSONLY_INC}
{$DEFINE WINDOWSONLY_INC}

// Suppress platform warnings which are irrelevant
// because the including unit can only be compiled
// for the Windows platform anyway.

{$IFDEF SUPPORTS_PLATFORM_WARNINGS}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF SUPPORTS_PLATFORM_WARNINGS}

// Cause a compilation error for any platform except Windows.

{$IFNDEF MSWINDOWS}
  {$IFDEF SUPPORTS_COMPILETIME_MESSAGES}
    {$MESSAGE FATAL 'This unit is only supported on Windows!'}
  {$ELSE}
    'This unit is only supported on Windows!'
  {$ENDIF SUPPORTS_COMPILETIME_MESSAGES}
{$ENDIF ~MSWINDOWS}

{$ENDIF ~WINDOWSONLY_INC}

