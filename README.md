# 🔍 Delphi Unit Dependency Analyzer + Grafo HTML Interativo

Ferramenta para análise de dependências entre units Delphi (`uses`) com geração de relatórios e visualizações gráficas interativas — ideal para auditoria técnica, refatorações, e controle de arquitetura em projetos legados.

## ✨ Funcionalidades

- 🔁 **Análise automática** de arquivos `.pas` e seus blocos `uses`
- 📊 Geração de **relatório CSV** com cada dependência cruzada
- 🌐 Geração de **grafo em HTML** com layout hierárquico (Vis.js)
- 🎯 Destaque visual para dependências suspeitas: `View → DAO`
- 🧠 Geração de grafo filtrado com apenas as Top N units mais referenciadas
- ✅ Versão **deluxe** com **filtros interativos por camada** (exibir apenas View, DAO, Controller etc.)
- 💡 Grafo hierárquico, estável e legível, sem movimentações automáticas

---

## 📦 Estrutura dos Relatórios Gerados

| Arquivo                         | Descrição                                                |
|--------------------------------|-----------------------------------------------------------|
| `RelatorioReferenciasUses.csv` | Todas as dependências `Origem → Referenciada`             |
| `grafoDependencias.html`       | Grafo completo com todas as units analisadas              |
| `grafoTop100.html`             | Grafo hierárquico com as 100 units mais referenciadas     |
| `grafoTop100Deluxe.html`       | Grafo com filtro interativo por camadas (View, DAO, etc.) |

---

## 📁 Exemplo visual (Deluxe)

![Exemplo do grafo com filtros](exemplo-grafo.png) <!-- substitua por sua imagem se tiver -->

No topo da página é possível interagir com filtros por camada:

☑ View   ☑ Controller   ☑ DAO   ☐ Service   ☐ Model

Basta marcar/desmarcar para refinar a análise visual em tempo real, sem recarregar a página.

---

## 🚀 Como utilizar

no diretorio da aplicação : ScannerAcoplamento.exe "C:\Fontes"

Requisitos 

- Projeto Delphi com estrutura de units modularizadas
- Compilador com suporte a generics (System.Generics.*)
- Navegador moderno (Chrome, Edge, Firefox)
📌 Observações- Dependências internas do Delphi como System.*, VCL.*, Winapi.* são automaticamente ignoradas
- Units com nomes contendo "view", "controller", "dao" etc. são automaticamente agrupadas por camada
- Conexões View → DAO aparecem em vermelho (violação de separação de camadas)

Integração com Jenkins (CI/CD)

É possível utilizar esta ferramenta diretamente em pipelines do Jenkins para automatizar a análise de dependências Delphi e geração de grafos.
✅ Pré-requisitos
- O projeto já deve estar compilado como .exe (ex: AnaliseDependencias.exe)
- Jenkins precisa ter acesso ao diretório do executável e dos fontes .pas
- Ambiente com Windows instalado no agente Jenkins
📁 Estrutura esperada no workspace
<workspace>/
├── AnaliseDependencias.exe
├── fontes/
│   └── *.pas
├── Relatorios/          ← será criado se não existir


📋 Exemplo de execução via pipeline declarativo
pipeline {
  agent any

  stages {
    stage('Executar Analisador') {
      steps {
        script {
          bat 'AnaliseDependencias.exe fontes'
        }
      }
    }

    stage('Publicar HTML do Grafo') {
      steps {
        archiveArtifacts artifacts: 'Relatorios/grafoTop100Deluxe.html', fingerprint: true
      }
    }
  }
}


💡 Resultado
- O grafo em HTML será gerado e salvo em Relatorios\grafoTop100Deluxe.html
- O Jenkins o disponibilizará como artefato para consulta/download
- Você pode agendar execuções periódicas ou disparar por push no repositório



