unit uRelatorioHTMLGrafo;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uAnaliseReferenciasUses;

type
  TRelatorioHTMLGrafo = class
  public
    class procedure Gerar(const Referencias: TList<TReferenciaUses>;
      const NomeArquivo: string = 'grafoDependencias.html');
  end;

implementation

function DeveIncluirNoGrafo(const NomeUnit: string): Boolean;
begin
  Result := not NomeUnit.ToLower.StartsWith('system.') and
    not NomeUnit.ToLower.StartsWith('vcl.') and not NomeUnit.ToLower.StartsWith
    ('winapi.') and not NomeUnit.ToLower.StartsWith('firedac.') and
    not NomeUnit.ToLower.StartsWith('data.') and not NomeUnit.ToLower.StartsWith
    ('rest.') and not NomeUnit.ToLower.StartsWith('soap.');
end;

function ExtrairCamada(const UnitName: string): string;
begin
  if UnitName.ToLower.Contains('view') then
    Exit('View');
  if UnitName.ToLower.Contains('controller') then
    Exit('Controller');
  if UnitName.ToLower.Contains('dao') then
    Exit('DAO');
  if UnitName.ToLower.Contains('service') then
    Exit('Service');
  if UnitName.ToLower.Contains('model') then
    Exit('Model');
  Result := 'Outro';
end;

class procedure TRelatorioHTMLGrafo.Gerar(const Referencias
  : TList<TReferenciaUses>; const NomeArquivo: string);
var
  html: TStringList;
  r: TReferenciaUses;
  unidadesUnicas: TDictionary<string, string>; // unit ? camada
begin
  html := TStringList.Create;
  unidadesUnicas := TDictionary<string, string>.Create;
  try
    // Coletar nodes �nicos que passam no filtro
    for r in Referencias do
    begin
      if DeveIncluirNoGrafo(r.Origem) then
        if not unidadesUnicas.ContainsKey(r.Origem) then
          unidadesUnicas.Add(r.Origem, ExtrairCamada(r.Origem));
      if DeveIncluirNoGrafo(r.Referenciada) then
        if not unidadesUnicas.ContainsKey(r.Referenciada) then
          unidadesUnicas.Add(r.Referenciada, ExtrairCamada(r.Referenciada));
    end;

    html.Add('<html><head><meta charset="utf-8"><title>Grafo de Depend�ncias</title>');
    html.Add('<script type="text/javascript" src="https://unpkg.com/vis-network@9.1.2/dist/vis-network.min.js"></script>');
    html.Add('<style> #grafo { width: 100%; height: 90vh; border: 1px solid lightgray; } </style></head><body>');
    html.Add('<h2 style="font-family: sans-serif">?? Grafo de Depend�ncias entre Units</h2>');
    html.Add('<div id="grafo"></div><script>');

    if unidadesUnicas.Count = 0 then
    begin
      html.Add('<h2 style="font-family: sans-serif; color: #999;">? Nenhuma depend�ncia entre units pr�prias foi encontrada.</h2>');
      html.Add('<p style="font-family: sans-serif;">O filtro ignorou bibliotecas padr�o (System, Vcl, etc.) e n�o sobrou nenhum relacionamento entre suas pr�prias units. Tente revisar o c�digo ou desativar o filtro para testar.</p>');
      html.SaveToFile(NomeArquivo, TEncoding.UTF8);
      Exit;
    end;

    // Nodes
    html.Add('var nodes = new vis.DataSet([');
    for var UnitName in unidadesUnicas.Keys do
    begin
      var
      grupo := unidadesUnicas[UnitName];
      html.Add(Format('{ id: "%s", label: "%s", group: "%s" },',
        [UnitName, UnitName, grupo]));
    end;
    html.Add(']);');

    // Edges
    html.Add('var edges = new vis.DataSet([');
    for r in Referencias do
      if DeveIncluirNoGrafo(r.Origem) and DeveIncluirNoGrafo(r.Referenciada)
      then
        html.Add(Format('{ from: "%s", to: "%s" },',
          [r.Origem, r.Referenciada]));
    html.Add(']);');

    // Visualiza��o
    html.Add('var container = document.getElementById("grafo");');
    html.Add('var data = { nodes: nodes, edges: edges };');
    html.Add('var options = {');
    html.Add('  groups: {');
    html.Add('    View: {color:{background:"#D1E8FF",border:"#3399FF"}},');
    html.Add('    DAO: {color:{background:"#FFF4D1",border:"#FFB800"}},');
    html.Add('    Service: {color:{background:"#D1FFD6",border:"#32C852"}},');
    html.Add('    Controller: {color:{background:"#FDE2E2",border:"#E74C3C"}},');
    html.Add('    Model: {color:{background:"#E2D1FF",border:"#9B59B6"}},');
    html.Add('    Outro: {color:{background:"#EEEEEE",border:"#999999"}}');
    html.Add('  },');
    html.Add('  layout: { improvedLayout: true },');
    html.Add('  physics: { stabilization: true },');
    html.Add('  nodes: { shape: "box", font: { size: 14 } },');
    html.Add('  edges: { arrows: { to: { enabled: true, scaleFactor: 0.5 } } }');
    html.Add('};');
    html.Add('var network = new vis.Network(container, data, options);');
    html.Add('</script></body></html>');

    html.SaveToFile(NomeArquivo, TEncoding.UTF8);
  finally
    unidadesUnicas.Free;
    html.Free;
  end;
end;

end.
