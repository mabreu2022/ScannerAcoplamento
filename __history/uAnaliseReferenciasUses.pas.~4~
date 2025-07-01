unit uAnaliseReferenciasUses;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.Generics.Collections,
  System.RegularExpressions,
  System.Types;

type
  TReferenciaUses = record
    Origem: string;
    Referenciada: string;
  end;

  TAnaliseUses = class
  public
    class function AnalisarPasta(const PastaFontes: string): TList<TReferenciaUses>;
  end;

implementation

class function TAnaliseUses.AnalisarPasta(const PastaFontes: string): TList<TReferenciaUses>;
var
  arquivos: TStringDynArray;
  arquivo, linha, unitOrigem: string;
  LReader: TStreamReader;
  i: Integer;
  partes: TArray<string>;
  item: TReferenciaUses;
begin
  Result := TList<TReferenciaUses>.Create;
  arquivos := TDirectory.GetFiles(PastaFontes, '*.pas', TSearchOption.soAllDirectories);

  for arquivo in arquivos do
  begin
    unitOrigem := TPath.GetFileNameWithoutExtension(arquivo);
    LReader := nil;

    try
      LReader := TStreamReader.Create(arquivo, TEncoding.Default);
      while not LReader.EndOfStream do
      begin
        linha := LReader.ReadLine.Trim;

        // Verifica início da seção uses
        if linha.ToLower.StartsWith('uses') then
        begin
          linha := linha.Substring(4).Trim;

          // Junta linhas até encontrar ponto e vírgula
          while not linha.EndsWith(';') and not LReader.EndOfStream do
            linha := linha + ' ' + LReader.ReadLine.Trim;

          linha := linha.Replace(';', '').Replace(#9, '').Trim;
          partes := linha.Split([',']);

          for i := 0 to High(partes) do
          begin
            item.Origem := unitOrigem;
            item.Referenciada := partes[i].Trim;
            if item.Referenciada <> '' then
              Result.Add(item);
          end;
        end;
      end;
    finally
      LReader.Free;
    end;
  end;
end;

end.
