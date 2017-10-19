unit uDWConstsData;

interface

Uses
 DB;

Type
 TSendEvent       = (seGET,       sePOST,
                     sePUT,       seDELETE);
 TTypeRequest     = (trHttp,      trHttps);
 TEncodeSelect    = (esASCII,     esUtf8);
 TObjectDirection = (odIN, odOUT, odINOUT);
 TDatasetEvents   = Procedure (DataSet: TDataSet) Of Object;

implementation

end.
