unit uRelatorioHTML;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TDependenciaInfo = record
    UnitName: string;
    Linha: Integer;
    Classe: string;
    DependeDe: string;
    Sugestao: string;
  end;

  TRelatorioHTML = class
  public
    class procedure Gerar(const Lista: TList<TDependenciaInfo>; const NomeArquivo: string = 'RelatorioAcoplamento.html');
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

{ TRelatorioHTML }

class procedure TRelatorioHTML.Gerar(const Lista: TList<TDependenciaInfo>; const NomeArquivo: string);
var
  html: TStringList;
  item: TDependenciaInfo;
begin
  html := TStringList.Create;
  try
    html.Add('<html>');
    html.Add('<head><meta charset="utf-8"><style>');
    html.Add('table { border-collapse: collapse; width: 100%; font-family: Arial; font-size: 14px; }');
    html.Add('th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }');
    html.Add('th { background-color: #f2f2f2; }');
    html.Add('</style></head><body>');
    html.Add('<h2>Relatório de Acoplamentos Encontrados</h2>');
    html.Add('<table>');
    html.Add('<tr><th>Unit</th><th>Linha</th><th>Classe</th><th>DependeDe</th><th>Sugestão</th><th>TipoDeClasse</th><th>Camada</th><th>Namespace</th><th>PossuiInterface</th></tr>');

    for item in Lista do
      html.Add(Format(
        '<tr><td>%s</td><td>%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>',
        [item.UnitName,
         item.Linha,
         item.Classe,
         item.DependeDe,
         item.Sugestao,
         InfereTipoClasse(item.DependeDe),
         ExtrairCamada(item.UnitName),
         ExtrairNamespace(item.UnitName),
         PossuiInterface(item.Sugestao)]));

    html.Add('</table></body></html>');
    html.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    html.Free;
  end;
end;

end.
