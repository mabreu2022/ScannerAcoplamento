unit uRelatorioCSVDetalhado;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.IOUtils,
  uRelatorioHTML; // usa TDependenciaInfo

type
  TRelatorioCSVDetalhado = class
  public
    class procedure Gerar(const Lista: TList<TDependenciaInfo>; const NomeArquivo: string = 'RelatorioAcoplamentoDetalhado.csv');
  end;

implementation

function InfereTipoClasse(const Tipo: string): string;
begin
  if Tipo.StartsWith('TDAO') then Exit('DAO');
  if Tipo.StartsWith('TService') then Exit('Service');
  if Tipo.Contains('Controller') then Exit('Controller');
  if Tipo.Contains('Form') then Exit('Form');
  Result := 'Outro';
end;

function ExtrairCamada(const UnitName: string): string;
begin
  if UnitName.ToLower.Contains('\view\') then Exit('View');
  if UnitName.ToLower.Contains('\dao\') then Exit('DAO');
  if UnitName.ToLower.Contains('\service\') then Exit('Service');
  if UnitName.ToLower.Contains('\controller\') then Exit('Controller');
  Result := 'Outro';
end;

function ExtrairNamespace(const UnitName: string): string;
begin
  Result := ExtractFilePath(UnitName).Trim(['/','\']);
end;

function PossuiInterface(const Sugestao: string): string;
begin
  if Sugestao.ToLower.Contains('interface') or Sugestao.ToLower.Contains('idao') then
    Exit('Sim')
  else
    Exit('Não');
end;

{ TRelatorioCSVDetalhado }

class procedure TRelatorioCSVDetalhado.Gerar(const Lista: TList<TDependenciaInfo>; const NomeArquivo: string);
var
  csv: TStringList;
  item: TDependenciaInfo;
  linha: string;
begin
  csv := TStringList.Create;
  try
    csv.Add('Unit,Linha,Classe,DependeDe,Sugestao,TipoDeClasse,Camada,Namespace,PossuiInterface');
    for item in Lista do
    begin
      linha := Format('"%s",%d,"%s","%s","%s","%s","%s","%s","%s"',
        [item.UnitName,
         item.Linha,
         item.Classe,
         item.DependeDe,
         item.Sugestao,
         InfereTipoClasse(item.DependeDe),
         ExtrairCamada(item.UnitName),
         ExtrairNamespace(item.UnitName),
         PossuiInterface(item.Sugestao)]);
      csv.Add(linha);
    end;

    csv.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    csv.Free;
  end;
end;

end.
