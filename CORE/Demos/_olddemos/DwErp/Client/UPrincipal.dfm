object FrmPrincipal: TFrmPrincipal
  Left = 426
  Top = 153
  Caption = 'EMS Cliente DW'
  ClientHeight = 424
  ClientWidth = 878
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = mnuPrincipal
  OldCreateOrder = True
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TJvStatusBar
    Left = 0
    Top = 405
    Width = 878
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 25
      end
      item
        Alignment = taCenter
        Text = '00/00/0000 00:00'
        Width = 100
      end
      item
        Alignment = taCenter
        Width = 180
      end
      item
        Alignment = taCenter
        Width = 300
      end
      item
        Width = 400
      end
      item
        Alignment = taRightJustify
        Width = 200
      end>
    object JvLED1: TJvLED
      Left = 3
      Top = 2
    end
  end
  object TimerAgenda: TTimer
    Interval = 10000
    OnTimer = TimerAgendaTimer
    Left = 800
    Top = 296
  end
  object mnuPrincipal: TMainMenu
    Left = 640
    Top = 43
    object Arquivo1: TMenuItem
      Caption = '&Arquivo'
      ImageIndex = 41
      object FinalizarAplicao1: TMenuItem
        Bitmap.Data = {
          36090000424D3609000000000000360000002800000018000000180000000100
          2000000000000009000000000000000000000000000000000000CDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF99A4A7FF0145
          68FF0D304CFF0F2A45FF0F2B46FF102A44FF043C5CFF105986FF266FA0FF2773
          A1FF206E9EFF2875A2FF2874A2FF2673A0FF206E9DFF2673A1FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF91A0A4FF0146
          6AFF0D2F4CFF0F2A45FF0F2B46FF102A45FF043D5EFF125B89FF2972A2FF2977
          A4FF2372A2FF2C7AA7FF2A77A4FF2875A2FF216E9EFF2875A2FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF82969EFF0144
          6DFF0D2D4AFF0F2B46FF0F2B46FF0F2B45FF043E60FF155E8CFF2C76A5FF2972
          9BFF1E5E84FF29698DFF2C78A2FF2B78A4FF226F9FFF2B77A3FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF748F9AFF0043
          47FF081D31FF0F2844FF0F2C47FF0F2B46FF033F61FF196291FF296F9BFF154C
          77FF0C3E6BFF113B5DFF215876FF2D78A2FF24719FFF2D79A4FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF6B8494FF065E
          1EFF084210FF051A27FF0F2643FF0F2D47FF034162FF1C6592FF185485FF0F51
          85FF135D92FF0D4D81FF133E5DFF296C91FF2573A2FF307CA6FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFB5ACA4FF8B8F7FFF315842FF1B6F
          28FF449647FF0E5015FF021B1FFF0C2340FF044466FF1B6190FF125083FF1863
          96FF1D6A9BFF165F93FF0F416CFF296889FF2675A2FF327FA7FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFB9B0A9FF617F58FF286E27FF1D7520FF2D8731FF4597
          4BFF5CA565FF55A05AFF1A611EFF00231BFF024165FF1F6695FF1B5485FF5683
          A1FF648FA9FF4A799CFF104671FF2E7397FF2775A2FF3580A9FFCDC3BAFFCDC3
          BAFFCDC3BAFFACAB9DFF2F752DFF1A8621FF2E9939FF3D9E47FF479F50FF50A0
          59FF57A160FF64A66DFF65A76AFF2D7439FF024861FF256F9EFF286693FF6F85
          9AFF949FA8FF577591FF24648CFF3681A9FF2875A2FF3682AAFFCDC3BAFFCDC3
          BAFFBAB4AAFF2C752AFF1A8F23FF289632FF309539FF399944FF459C4EFF4E9F
          57FF57A160FF60A368FF71AD78FF5D9D6DFF08516BFF28719FFF3983ACFF296B
          97FF2F6993FF30749DFF3B86ADFF3883ABFF2975A2FF3985ACFFCDC3BAFFCDC3
          BAFF55864EFF11891BFF1E9229FF289632FF319B3CFF399C41FF409943FF4D9D
          54FF58A260FF66A86DFF539A55FF145C2CFF03496CFF2B75A2FF3D87AEFF2F7C
          A7FF317FA9FF3E8BB1FF3D88AEFF3985ACFF2976A3FF3B86ADFFCDC3BAFFB0B1
          A0FF117715FF169322FF1B9024FF177F1DFF2C7D2DFF3F813FFF146234FF2378
          30FF5DA763FF418F44FF0C4B1EFF062D41FF054B73FF2F78A4FF3A89B0FF2578
          A7FF2D7FACFF3789B1FF3688B0FF3284AEFF2073A4FF3486AFFFCDC3BAFF829C
          76FF0C8914FF0D7F14FF3C7E39FF8D9F81FFBDB7ADFFBDB6B5FF1A5173FF126A
          2BFF2F8230FF074020FF0C2741FF0C2F4FFF074E75FF307AA7FF508EABFF5E8B
          9DFF6995A3FF739BA6FF769BA4FF7598A3FF75959DFF86A2A3FFCDC3BAFF6C97
          63FF06770AFF67885EFFC9C0B8FFCDC3BAFFCDC3BAFFB1B2B1FF0E4F70FF0454
          25FF073826FF0E2746FF102A47FF0A314FFF085178FF377FA8FFA8A599FFCDB6
          A0FFC7B2A5FFC1ADA5FFC9B3A6FFCDC0A7FFC0AAA8FFB49FA8FFCDC3BAFF5F8F
          57FF336A2EFFCBC1B9FFCDC3BAFFCDC3BAFFCDC3BAFFA7ACACFF084A6DFF0B32
          4CFF0F2847FF0F2B47FF102A44FF093350FF09537BFF4586A7FFA9A19FFF4B42
          AFFF3B34B0FF5A54B2FF564EB2FF9D94B7FF4E46B2FF524BB2FFCDC3BAFF89A1
          7DFF94A087FFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF9CA6A9FF034769FF0D2F
          4DFF0F2A45FF0F2B46FF102A44FF083451FF0C557DFF4B8AAAFFA09BA4FF3831
          B0FF9C93B8FFB7ADBAFF6158B3FF2B23AFFF8980B6FF948BB7FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF8F9EA4FF014569FF0D2F
          4BFF0F2A45FF0F2B46FF102A44FF083553FF0D5881FF508DACFFA7A0A4FF322A
          AFFF4941B1FF9B92B7FFA096B7FF160FADFFBCB2BAFF9A90B6FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF83969FFF01466BFF0D2E
          4AFF0F2A45FF0F2B46FF102A44FF063756FF105B84FF5590ADFFA89EA4FF352E
          AFFF7971B5FFA69DB8FF5D54B2FF3930AFFF6E65B4FF786FB5FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF7A929BFF01466BFF0D2D
          4AFF0F2A45FF0F2B46FF102A44FF043959FF115E87FF5A93ADFFADA3A5FF3730
          B0FF453EB2FF665DB4FF5D54B3FFB1A9B9FF6B63B4FF6E66B5FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF708C98FF034367FF0F2B
          46FF0F2B45FF0F2B46FF102A44FF043A5BFF14618BFF5E93ADFFC5B2A2FFB3A8
          B6FFB5AAB6FFBFB3B5FFCCBEB5FFCDC3B4FFCDC3B2FFCDC3B0FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF698895FF034265FF102A
          44FF102A45FF102A45FF102A43FF033C5DFF18648EFF5A92ADFFCDB095FFCDC0
          A2FFCDBDA3FFCDBAA1FFCDB69FFFC4B19FFFBDAF9FFFB2ACA1FFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF6D8996FF004B72FF0444
          68FF044468FF044468FF044468FF004568FF1C6590FF428BB5FF7999A6FF829D
          A7FF7299AAFF6696ADFF5A92AEFF4F8CADFF4689ADFF3A82AAFFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFB6B6B2FF708C98FF6888
          96FF698996FF698996FF6B8997FF1B5876FF155F8CFF2D76A4FF2474A2FF1F6F
          9DFF196B99FF136593FF0F608DFF0A5A86FF075580FF04517BFFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFF437187FF004E76FF014B73FF04486DFF1250
          70FF215876FF30617BFF426C83FF5A7B8CFF708994FF87979EFFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3
          BAFFCDC3BAFFCDC3BAFFCDC3BAFFA9AEADFF7B929CFF9BA3A6FFB0B1AFFFBEBA
          B5FFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFFCDC3BAFF}
        Caption = '&Sair'
        ImageIndex = 2
        OnClick = FinalizarAplicao1Click
      end
    end
    object Cadastros1: TMenuItem
      Caption = '&Cadastros'
      ImageIndex = 41
      object C1: TMenuItem
        Caption = 'Cadastro Basico  ( Master )'
        OnClick = C1Click
      end
    end
  end
end
