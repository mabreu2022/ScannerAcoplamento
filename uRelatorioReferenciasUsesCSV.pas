unit uRelatorioReferenciasUsesCSV;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uAnaliseReferenciasUses;

type
  TRelatorioReferenciasUsesCSV = class
  public
    class procedure Gerar(const Referencias: TList<TReferenciaUses>; const NomeArquivo: string = 'RelatorioReferenciasUses.csv');
  end;

implementation

function ExtrairCamada(const UnitName: string): string;
begin
  if UnitName.ToLower.Contains('view') then Exit('View');
  if UnitName.ToLower.Contains('controller') then Exit('Controller');
  if UnitName.ToLower.Contains('dao') then Exit('DAO');
  if UnitName.ToLower.Contains('service') then Exit('Service');
  if UnitName.ToLower.Contains('model') then Exit('Model');
  Result := 'Outro';
end;

function MesmoNamespace(const Origem, Destino: string): string;
begin
  if ExtractFilePath(Origem).ToLower = ExtractFilePath(Destino).ToLower then
    Result := 'Sim'
  else
    Result := 'Não';
end;

function BuscarDependencias(const Origem: string; Lista: TList<TReferenciaUses>): TList<string>;
var
  r: TReferenciaUses;
begin
  Result := TList<string>.Create;
  for r in Lista do
    if SameText(r.Origem, Origem) then
      Result.Add(r.Referenciada);
end;

function ExisteReferenciaInversa(const Origem, Destino: string; const Lista: TList<TReferenciaUses>): Boolean;
var
  r: TReferenciaUses;
begin
  Result := False;
  for r in Lista do
    if SameText(r.Origem, Destino) and SameText(r.Referenciada, Origem) then
      Exit(True);
end;

{ TRelatorioReferenciasUsesCSV }

class procedure TRelatorioReferenciasUsesCSV.Gerar(const Referencias: TList<TReferenciaUses>; const NomeArquivo: string);
var
  csv: TStringList;
  r: TReferenciaUses;
  camadaOrigem, camadaDestino, ciclo, mesmoNS: string;
begin
  csv := TStringList.Create;
  try
    csv.Add('UnitOrigem,Referenciada,CamadaOrigem,CamadaDestino,TipoDependencia,MesmoNamespace');

    for r in Referencias do
    begin
      camadaOrigem := ExtrairCamada(r.Origem);
      camadaDestino := ExtrairCamada(r.Referenciada);
      mesmoNS := MesmoNamespace(r.Origem, r.Referenciada);

      if ExisteReferenciaInversa(r.Origem, r.Referenciada, Referencias) then
        ciclo := 'Cruzada'
      else
        ciclo := 'Direta';

      csv.Add(Format('"%s","%s","%s","%s","%s","%s"',
        [r.Origem, r.Referenciada, camadaOrigem, camadaDestino, ciclo, mesmoNS]));
    end;

    csv.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    csv.Free;
  end;
end;

end.
