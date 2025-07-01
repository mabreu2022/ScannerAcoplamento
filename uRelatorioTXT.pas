unit uRelatorioTXT;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  TRelatorioTXT = class
  public
    class procedure Gerar(const Dependencias: TDictionary<string, TList<string>>; const NomeArquivo: string = 'RelatorioAcoplamento.txt');
  end;

implementation

{ TRelatorioTXT }

class procedure TRelatorioTXT.Gerar(const Dependencias: TDictionary<string, TList<string>>; const NomeArquivo: string);
var
  txt: TStringList;
  classe, depende: string;
  par: TPair<string, TList<string>>;
begin
  txt := TStringList.Create;
  try
    txt.Add('RELATÓRIO DE DEPENDÊNCIAS ENTRE CLASSES');
    txt.Add('========================================');
    txt.Add('');

    for par in Dependencias do
    begin
      classe := par.Key;
      txt.Add(Format('%s depende de:', [classe]));

      for depende in par.Value do
        txt.Add('  - ' + depende);

      txt.Add('');
    end;

    txt.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    txt.Free;
  end;
end;

end.
