# Microplastic Detection – MATLAB Image Analysis Framework

Automated framework for detection, segmentation, morphological
characterization and classification of microplastic particles in
fluorescence microscopy images. Developed at Universidade do Minho
under the RESOLVE project.

---

## Overview

This system processes Nile Red fluorescence microscopy images through
a classical image-processing pipeline and exports per-particle metrics,
classification results, and statistical reports — for both individual
images and large batches — without requiring manual intervention or
annotated training data.

---

## Features

- Fluorescence channel extraction and enhancement (Top-Hat, CLAHE)
- Hybrid thresholding (Otsu + local adaptive, logical conjunction)
- Morphological refinement and selective watershed aggregate separation
- Automatic extraction of geometric descriptors (area, length, width,
  sphericity, compactness, eccentricity, circularity)
- Rule-based classification into **Fiber, Fragment, Film, Bead, Aggregate**
- Single-image and batch-processing modes
- Automatic Excel dataset and HTML report generation
- TIFF metadata extraction for physical scale calibration (µm/pixel)

---

## File Structure

| File | Description |
|---|---|
| `corpo.m` | Main processing pipeline |
| `bin_itr.m` | Hybrid thresholding module |
| `adquirir.m` | Image acquisition and file selection |
| `euclidean.m` | Morphological feature computation |
| `gravar.m` | Save segmentation results |
| `gravar_param.m` | Save per-particle parameters |
| `gravar_log.m` | Save processing log |
| `gerar_relatorio_html.m` | Generate individual HTML report |
| `gerar_relatorio_lote.m` | Generate batch HTML report |
| `final.m` | Cleanup and close session |

> Some files are legacy or auxiliary and may not be active in the
> current App Designer workflow.

---

## Requirements

- MATLAB R2021a or later
- Image Processing Toolbox

---

## Usage

### Single Image
Run the MATLAB App Designer GUI, select **single-image mode**, choose
a `.bmp`, `.tif` or `.jpg` file and click process.

### Batch Processing
Select **batch mode** and point to a folder containing microscopy images.
Results are saved automatically to:
- `Resultados_Globais.xlsx` — per-particle Excel dataset
- `relatorio_global.html` — global HTML report with charts

---

## Output

Each analysis produces:
- Segmented image overlay (green contour on original)
- Area and length distribution histograms
- Particle class distribution pie chart
- Per-particle morphological metrics table

---

## Authors

Fábio Mendes, Daniela Mesquita, Danilo Oliveira, Anália Lourenço  
Universidade do Minho, Braga, Portugal
