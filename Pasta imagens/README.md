# Pasta-Imagens

Imagens de exemplo utilizadas para validação do framework **PlastID**.

---

## Conteúdo

| Ficheiro | Descrição |
|---|---|
| `*.tif` | Imagens de microscopia de fluorescência com coloração Nile Red |
| `*_otsu.png` / `*_otsu.tif` | Máscara binária resultante do threshold de Otsu para cada imagem |
| `Resultados_Globais.xlsx` | Dataset Excel com métricas morfológicas por partícula de todas as imagens processadas |

---

## Notas

- As imagens TIF contêm metadados de calibração espacial (µm/pixel) extraídos
  automaticamente pelo PlastID durante o processamento.
- Os resultados globais foram gerados pelo módulo de processamento em lote
  (`processar_lote.m`) e incluem área, comprimento, classe e restantes
  descritores morfológicos por partícula.
