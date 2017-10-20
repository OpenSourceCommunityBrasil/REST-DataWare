unit uDWConstsData;

interface

Uses
 DB;

Type
 TSendEvent       = (seGET,       sePOST,
                     sePUT,       seDELETE);
 TTypeRequest     = (trHttp,      trHttps);
 TEncodeSelect    = (esASCII,     esUtf8);
 TDatabaseCharSet = (csUndefined, csWin1250, csWin1251, csWin1252,
                     csWin1253,   csWin1254, csWin1255, csWin1256,
                     csWin1257,   csWin1258);
 TObjectDirection = (odIN, odOUT, odINOUT);
 TDatasetEvents   = Procedure (DataSet: TDataSet) Of Object;

implementation

end.
