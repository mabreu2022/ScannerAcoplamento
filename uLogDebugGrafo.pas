unit uLogDebugGrafo;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uAnaliseReferenciasUses;

type
  TLogDebugGrafo = class
  public
    class procedure Registrar(const Referencias: TList<TReferenciaUses>; const NomeArquivo: string = 'Relatorios\logGrafo.txt');
  end;

implementation

function DeveIncluirNoGrafo(const NomeUnit: string): Boolean;
begin
  Result :=
    not NomeUnit.ToLower.StartsWith('system.') and
    not NomeUnit.ToLower.StartsWith('vcl.') and
    not NomeUnit.ToLower.StartsWith('winapi.') and
    not NomeUnit.ToLower.StartsWith('firedac.') and
    not NomeUnit.ToLower.StartsWith('data.') and
    not NomeUnit.ToLower.StartsWith('rest.') and
    not NomeUnit.ToLower.StartsWith('soap.');
end;

{ TLogDebugGrafo }

class procedure TLogDebugGrafo.Registrar(const Referencias: TList<TReferenciaUses>; const NomeArquivo: string);
var
  log: TStringList;
  r: TReferenciaUses;
  incluidas, ignoradas: TDictionary<string, Boolean>;
  contIncluidas, contIgnoradas: Integer;
begin
  log := TStringList.Create;
  incluidas := TDictionary<string, Boolean>.Create;
  ignoradas := TDictionary<string, Boolean>.Create;
  try
    log.Add('?? Log de Diagnóstico do Grafo');
    log.Add('------------------------------');
    log.Add('Total de referências analisadas: ' + Referencias.Count.ToString);
    contIncluidas := 0;
    contIgnoradas := 0;

    for r in Referencias do
    begin
      if DeveIncluirNoGrafo(r.Origem) and DeveIncluirNoGrafo(r.Referenciada) then
      begin
        if not incluidas.ContainsKey(r.Origem) then
          incluidas.Add(r.Origem, True);
        if not incluidas.ContainsKey(r.Referenciada) then
          incluidas.Add(r.Referenciada, True);
        Inc(contIncluidas);
      end
      else
      begin
        if not DeveIncluirNoGrafo(r.Origem) then
          ignoradas.TryAdd(r.Origem, True);
        if not DeveIncluirNoGrafo(r.Referenciada) then
          ignoradas.TryAdd(r.Referenciada, True);
        Inc(contIgnoradas);
      end;
    end;

    log.Add('');
    log.Add('? Units incluídas no grafo: ' + incluidas.Count.ToString);
    log.Add('? Units ignoradas por padrão: ' + ignoradas.Count.ToString);
    log.Add('?? Conexões incluídas: ' + contIncluidas.ToString);
    log.Add('?? Conexões ignoradas: ' + contIgnoradas.ToString);
    log.Add('');
    log.Add('Exemplos de units ignoradas:');
    for var nome in ignoradas.Keys do
    begin
      log.Add(' - ' + nome);
      if log.Count > 50 then Break; // limita pra não gerar log gigante
    end;

    log.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    ignoradas.Free;
    incluidas.Free;
    log.Free;
  end;
end;

end.
