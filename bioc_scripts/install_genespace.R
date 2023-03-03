install.packages("BiocManager", repos="https://cran.rstudio.com")
BiocManager::install(version="3.16", update=TRUE, ask=FALSE)
BiocManager::install(c('devtools'))
install.packages("pacman")
install.packages("RcppParallel")
install.packages(
  c(
    "remotes",
    "kableExtra",
    "tidyverse",
    "cowplot",
    "RColorBrewer",
    "pheatmap",
    "scales",
    "tidytext",
    "reticulate",
    "plotly",
    "R.utils",
    "patchwork",
    "gridExtra",
    "calibrate",
    "ggrepel",
    "tidyr"
  )
)

BiocManager::install(c(
  "Rsamtools",
  "BiocGenerics",
  "S4Vectors",
  "ComplexHeatmap",
  "Biostrings",
  "rtracklayer"
))
install.packages("data.table")
BiocManager::install("IRanges")
BiocManager::install("GenomicRanges")
devtools::install_github("jtlovell/GENESPACE@dev", auth_token = "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")
