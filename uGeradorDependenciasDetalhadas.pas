unit uGeradorDependenciasDetalhadas;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.RegularExpressions,
  System.Types,
  System.Generics.Collections,
  Math,
  uRelatorioHTML;

type
  TGeradorDependencias = class
  public
    class function Gerar(const PastaFontes: string): TList<TDependenciaInfo>;
  end;

implementation

function GerarSugestao(const Tipo: string): string;
begin
  if Tipo.StartsWith('TDAO') then
    Exit('Substituir por interface (ex: IDAO)');
  if Tipo.StartsWith('TService') then
    Exit('Extrair dependência para camada intermediária');
  if Tipo.Contains('Controller') then
    Exit('Avaliar inversão de dependência');
  Result := 'Avaliar uso de interface ou injeção de dependência';
end;

function AbrirLeitorComEncodingFallback(const Arquivo: string): TStreamReader;
var
  fs: TFileStream;
  buffer: TBytes;
  encoding: TEncoding;
begin
  Result := nil;
  fs := nil;
  try
    fs := TFileStream.Create(Arquivo, fmOpenRead or fmShareDenyNone);

    SetLength(buffer, Min(4096, fs.Size));
    if Length(buffer) > 0 then
      fs.ReadBuffer(buffer[0], Length(buffer));

    fs.Position := 0;

    encoding := nil;
    TEncoding.GetBufferEncoding(buffer, encoding);
    if not Assigned(encoding) then
      encoding := TEncoding.UTF8;

    Result := TStreamReader.Create(fs, encoding, False);
  except
    fs.Free;
    FreeAndNil(Result);
  end;
end;

class function TGeradorDependencias.Gerar(const PastaFontes: string): TList<TDependenciaInfo>;
var
  arquivos: TStringDynArray;
  ignorados: TList<string>;
  arquivo, linha, classeAtual, unitAtual: string;
  LReader: TStreamReader;
  iLinha, arquivosProcessados: Integer;
  info: TDependenciaInfo;
  match: TMatch;
begin
  Result := TList<TDependenciaInfo>.Create;
  ignorados := TList<string>.Create;
  try
    arquivos := TDirectory.GetFiles(PastaFontes, '*.pas', TSearchOption.soAllDirectories);
    Writeln(Format('📂 %d arquivos .pas encontrados para análise.', [Length(arquivos)]));
    arquivosProcessados := 0;

    for arquivo in arquivos do
    begin
      unitAtual := StringReplace(arquivo, IncludeTrailingPathDelimiter(PastaFontes), '', []);
      iLinha := 0;
      classeAtual := '';

      LReader := AbrirLeitorComEncodingFallback(arquivo);
      if not Assigned(LReader) then
      begin
        ignorados.Add(unitAtual);
        Continue;
      end;

      try
        while not LReader.EndOfStream do
        begin
          Inc(iLinha);
          linha := LReader.ReadLine.Trim;

          // Detecta definição de classe
          match := TRegEx.Match(linha, 'type\s+(T\w+)\s*=\s*class', [roIgnoreCase]);
          if match.Success then
          begin
            classeAtual := match.Groups[1].Value;
            Continue;
          end;

          // Detecta propriedades com tipos concretos
          match := TRegEx.Match(linha, '(\w+):\s*(T\w+);', [roIgnoreCase]);
          if match.Success and (classeAtual <> '') then
          begin
            info.UnitName := unitAtual;
            info.Linha := iLinha;
            info.Classe := classeAtual;
            info.DependeDe := match.Groups[2].Value;
            info.Sugestao := GerarSugestao(info.DependeDe);
            Result.Add(info);
          end;
        end;
        Inc(arquivosProcessados);
      finally
        LReader.Free;
      end;
    end;

    // Resumo no final
    Writeln(Format('✅ %d arquivos analisados com sucesso.', [arquivosProcessados]));
    Writeln(Format('🚫 %d arquivos ignorados por erro de leitura.', [ignorados.Count]));

    if ignorados.Count > 0 then
    begin
      Writeln('📄 Arquivos ignorados:');
      for arquivo in ignorados do
        Writeln('   - ', arquivo);
    end;

  finally
    ignorados.Free;
  end;
end;

end.
