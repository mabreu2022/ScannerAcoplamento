unit uScannerRTTI;

interface

uses
  System.Rtti,
  System.Generics.Collections;

type
  TDependenciaMap = TDictionary<string, TList<string>>;

  TScannerRTTI = class
  public
    class function ColetarDependencias: TDependenciaMap;
  end;

implementation

uses
  System.SysUtils;

{ TScannerRTTI }

class function TScannerRTTI.ColetarDependencias: TDependenciaMap;
var
  ctx: TRttiContext;
  tipo, propTipo: TRttiType;
  prop: TRttiProperty;
  nomeClasse, nomeDependente: string;
begin
  Result := TDependenciaMap.Create;
  ctx := TRttiContext.Create;
  try
    for tipo in ctx.GetTypes do
    begin
      if not tipo.IsInstance then
        Continue;

      nomeClasse := tipo.QualifiedName;

      for prop in tipo.GetProperties do
      begin
        propTipo := prop.PropertyType;
        if not Assigned(propTipo) then
          Continue;

        nomeDependente := propTipo.QualifiedName;

        if nomeDependente.StartsWith('System.') then
          Continue;

        if not Result.ContainsKey(nomeClasse) then
          Result.Add(nomeClasse, TList<string>.Create);

        if not Result[nomeClasse].Contains(nomeDependente) then
          Result[nomeClasse].Add(nomeDependente);
      end;
    end;
  finally
    ctx.Free;
  end;
end;

end.
