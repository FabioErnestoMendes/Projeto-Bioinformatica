# Deteção de Microplásticos – Framework de Análise de Imagem em MATLAB

Framework automatizado para deteção, segmentação, caracterização morfológica
e classificação de partículas de microplásticos em imagens de microscopia de
fluorescência. Desenvolvido na Universidade do Minho no âmbito do projeto RESOLVE.

---

## Visão Geral

O sistema processa imagens de microscopia de fluorescência com coloração Nile Red
através de um pipeline clássico de processamento de imagem, exportando métricas
por partícula, resultados de classificação e relatórios estatísticos — tanto para
imagens individuais como para grandes lotes — sem necessitar de intervenção manual
ou dados de treino anotados.

---

## Funcionalidades

- Extração e realce do canal fluorescente (Top-Hat, CLAHE)
- Limiarização híbrida (Otsu + adaptativa local, conjunção lógica)
- Refinamento morfológico e separação de agregados por watershed seletivo
- Extração automática de descritores geométricos (área, comprimento, largura,
  esfericidade, compacidade, excentricidade, circularidade)
- Classificação automática em **Fiber, Fragment, Film, Bead, Agregate**
- Modos de processamento de imagem individual e em lote
- Geração automática de dataset Excel e relatório HTML
- Extração de metadados TIFF para calibração de escala física (µm/pixel)

---

## Estrutura de Ficheiros

| Ficheiro | Descrição |
|---|---|
| `corpo.m` | Pipeline principal de processamento |
| `bin_itr.m` | Módulo de limiarização híbrida |
| `adquirir.m` | Aquisição de imagem e seleção de ficheiro |
| `euclidean.m` | Cálculo de descritores morfológicos |
| `fluo_red.m` | Processamento do canal de fluorescência vermelha |
| `processar_lote.m` | Controlador de processamento em lote |
| `PlastID.m` | Ponto de entrada da aplicação (App Designer) |
| `gravar.m` | Gravação dos resultados de segmentação |
| `gravar_param.m` | Gravação dos parâmetros por partícula |
| `gravar_log.m` | Gravação do log de processamento |
| `gerar_relatorio_html.m` | Geração do relatório HTML individual |
| `gerar_relatorio_lote.m` | Geração do relatório HTML em lote |
| `fina.m` | Limpeza e fecho da sessão |
| `esc_avc.m` | Callback GUI – seleção do modo de análise |
| `esc_dcv.m` | Callback GUI – ativação da desconvolução |
| `esc_flr.m` | Callback GUI – seleção do canal fluorescente |
| `esc_lim.m` | Callback GUI – limites manuais de threshold |
| `esc_pre.m` | Callback GUI – opções de pré-tratamento |
| `esc_ser.m` | Callback GUI – modo série/imagem individual |
| `esc_trtg.m` | Callback GUI – opções de tratamento de partículas |
| `esc_trtl.m` | Callback GUI – opções de tratamento de fluorescência |
| `teste.m` | Script de desenvolvimento e testes (não usado em produção) |

> Os ficheiros com prefixo `esc_` são callbacks legacy da interface antiga baseada
> em menus e não estão ativos no workflow atual do App Designer.
> O `teste.m` é um script de desenvolvimento mantido apenas para referência.

---

## Requisitos

- MATLAB R2021a ou superior
- Image Processing Toolbox

---

## Utilização

### Imagem Individual
Executar `PlastID.m` via MATLAB App Designer, selecionar o modo **imagem individual**,
escolher um ficheiro `.bmp`, `.tif` ou `.jpg` e iniciar o processamento.

### Processamento em Lote
Selecionar o modo **lote** e indicar uma pasta com imagens de microscopia.
Os resultados são guardados automaticamente em:
- `Resultados_Globais.xlsx` — dataset Excel por partícula
- `relatorio_global.html` — relatório HTML global com gráficos

---

## Resultados

Cada análise produz:
- Imagem segmentada com contorno verde sobre a imagem original
- Histogramas de distribuição de área e comprimento
- Gráfico circular de distribuição de classes de partículas
- Tabela de métricas morfológicas por partícula

---

## Autores

Fábio Mendes, Daniela Mesquita, Danilo Oliveira, Anália Lourenço  
Universidade do Minho, Braga, Portugal
