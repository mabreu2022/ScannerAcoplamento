unit uRelatorioCSV;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  TRelatorioCSV = class
  public
    class procedure Gerar(const Dependencias: TDictionary<string, TList<string>>; const NomeArquivo: string = 'RelatorioAcoplamento.csv');
  end;

implementation

{ TRelatorioCSV }

class procedure TRelatorioCSV.Gerar(const Dependencias: TDictionary<string, TList<string>>; const NomeArquivo: string);
var
  csv: TStringList;
  classe, depende: string;
  par: TPair<string, TList<string>>;
begin
  csv := TStringList.Create;
  try
    csv.Add('Classe,DependeDe');

    for par in Dependencias do
    begin
      classe := par.Key;
      for depende in par.Value do
        csv.Add(Format('"%s","%s"', [classe, depende]));
    end;

    csv.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    csv.Free;
  end;
end;

end.
