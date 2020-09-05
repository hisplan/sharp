# hto-demux-seurat

- R version 3.6.3 (2020-02-29)
- Seurat 3.2.0

```R
> sessionInfo()
R version 3.6.3 (2020-02-29)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 20.04 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0

locale:
[1] C

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
[1] Seurat_3.2.0

loaded via a namespace (and not attached):
 [1] httr_1.4.2            tidyr_1.1.2           jsonlite_1.7.0
 [4] viridisLite_0.3.0     splines_3.6.3         leiden_0.3.3
 [7] shiny_1.5.0           ggrepel_0.8.2         globals_0.12.5
[10] pillar_1.4.6          lattice_0.20-40       glue_1.4.2
[13] reticulate_1.16       digest_0.6.25         polyclip_1.10-0
[16] RColorBrewer_1.1-2    promises_1.1.1        colorspace_1.4-1
[19] cowplot_1.0.0         htmltools_0.5.0       httpuv_1.5.4
[22] Matrix_1.2-18         plyr_1.8.6            pkgconfig_2.0.3
[25] listenv_0.8.0         purrr_0.3.4           xtable_1.8-4
[28] patchwork_1.0.1       scales_1.1.1          RANN_2.6.1
[31] tensor_1.5            later_1.1.0.1         Rtsne_0.15
[34] spatstat.utils_1.17-0 tibble_3.0.3          mgcv_1.8-31
[37] generics_0.0.2        ggplot2_3.3.2         ellipsis_0.3.1
[40] ROCR_1.0-11           pbapply_1.4-3         lazyeval_0.2.2
[43] deldir_0.1-28         survival_3.1-8        magrittr_1.5
[46] crayon_1.3.4          mime_0.9              future_1.18.0
[49] nlme_3.1-144          MASS_7.3-51.5         ica_1.0-2
[52] tools_3.6.3           fitdistrplus_1.1-1    data.table_1.13.0
[55] lifecycle_0.2.0       stringr_1.4.0         plotly_4.9.2.1
[58] munsell_0.5.0         cluster_2.1.0         irlba_2.3.3
[61] compiler_3.6.3        rsvd_1.0.3            rlang_0.4.7
[64] grid_3.6.3            ggridges_0.5.2        goftest_1.2-2
[67] RcppAnnoy_0.0.16      rappdirs_0.3.1        htmlwidgets_1.5.1
[70] igraph_1.2.5          miniUI_0.1.1.1        gtable_0.3.0
[73] codetools_0.2-16      abind_1.4-5           reshape2_1.4.4
[76] R6_2.4.1              gridExtra_2.3         zoo_1.8-8
[79] dplyr_1.0.2           uwot_0.1.8            fastmap_1.0.1
[82] future.apply_1.6.0    KernSmooth_2.23-16    ape_5.4-1
[85] spatstat.data_1.4-3   stringi_1.4.6         spatstat_1.64-1
[88] parallel_3.6.3        Rcpp_1.0.5            rpart_4.1-15
[91] vctrs_0.3.4           sctransform_0.2.1     png_0.1-7
[94] tidyselect_1.1.0      lmtest_0.9-37
```

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hto-demux-seurat:0.6.0
```

```bash
$ python3 correct_fp_doublets.py \
    --hto-classification /data/test.csv \
    --hto-umi-count-dir /data/umi_count
```
