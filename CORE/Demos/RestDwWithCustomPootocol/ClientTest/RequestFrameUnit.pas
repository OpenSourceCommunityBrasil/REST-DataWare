unit RequestFrameUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, JvMemoryDataset,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TRequestFrame = class(TFrame)
    ResponseDBGrid: TDBGrid;
    ResponseDataSource: TDataSource;
    Panel1: TPanel;
    DMLTypeRadioGroup: TRadioGroup;
    Panel2: TPanel;
    SqlMemo: TMemo;
    ParamsDBGrid: TDBGrid;
    ParamsDataSource: TDataSource;
    ResponseDataSet: TFDMemTable;
    ParamsDataSet: TFDMemTable;
    ParamTypeDataset: TFDMemTable;
    ParamTypeDataSource: TDataSource;
    ParamsDataSetPARAM_NAME: TStringField;
    ParamsDataSetPARAM_TYPE: TIntegerField;
    ParamsDataSetPARAM_VALUE: TStringField;
    ParamTypeDatasetCODE: TIntegerField;
    ParamTypeDatasetDESCRIPTION: TStringField;
    ParamsDataSetPARA_TYPE_DESCRIPTION: TStringField;
  private
    { Private declarations }
  public
    procedure AfterConstruction; override;
  end;

implementation

{$R *.dfm}

{ TRequestFrame }

procedure TRequestFrame.AfterConstruction;
begin
  inherited;

  ParamTypeDataset.InsertRecord([Ord(ftUnknown), 'ftUnknown']);
  ParamTypeDataset.InsertRecord([Ord(ftString), 'ftString']);
  ParamTypeDataset.InsertRecord([Ord(ftSmallint), 'ftSmallint']);
  ParamTypeDataset.InsertRecord([Ord(ftInteger), 'ftInteger']);
  ParamTypeDataset.InsertRecord([Ord(ftWord), 'ftWord']);
  ParamTypeDataset.InsertRecord([Ord(ftBoolean), 'ftBoolean']);
  ParamTypeDataset.InsertRecord([Ord(ftFloat), 'ftFloat']);
  ParamTypeDataset.InsertRecord([Ord(ftCurrency), 'ftCurrency']);
  ParamTypeDataset.InsertRecord([Ord(ftBCD), 'ftBCD']);
  ParamTypeDataset.InsertRecord([Ord(ftDate), 'ftDate']);
  ParamTypeDataset.InsertRecord([Ord(ftTime), 'ftTime']);
  ParamTypeDataset.InsertRecord([Ord(ftDateTime), 'ftDateTime']);
  ParamTypeDataset.InsertRecord([Ord(ftBytes), 'ftBytes']);
  ParamTypeDataset.InsertRecord([Ord(ftVarBytes), 'ftVarBytes']);
  ParamTypeDataset.InsertRecord([Ord(ftAutoInc), 'ftAutoInc']);
  ParamTypeDataset.InsertRecord([Ord(ftBlob), 'ftBlob']);
  ParamTypeDataset.InsertRecord([Ord(ftMemo), 'ftMemo']);

{
  FieldTypes
  ==========
  ftUnknown, ftString, ftSmallint, ftInteger, ftWord, // 0..4
  ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime, // 5..11
  ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo, // 12..18
  ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar, ftWideString, // 19..24
  ftLargeint, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob, // 25..31
  ftVariant, ftInterface, ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd, // 32..37
  ftFixedWideChar, ftWideMemo, ftOraTimeStamp, ftOraInterval, // 38..41
  ftLongWord, ftShortint, ftByte, ftExtended, ftConnection, ftParams, ftStream, //42..48
  ftTimeStampOffset, ftObject, ftSingle); //49..51
}
end;

end.
