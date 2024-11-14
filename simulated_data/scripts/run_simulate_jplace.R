library(ggtree)
library(treeio)
library(tidytree)
library(jsonlite)
options(digits=10)
source('../src/simulated_jplace_file.R')


tips <- c(1000, 10000, 50000, 100000)
place_nrows <- c(1000, 10000, 100000, 1000000)
for (i in tips){
  for (j in place_nrows){
    file <- paste0("../simulated_jplace/simulate_tips", as.character(tips),"_placement_nrow_", as.character(j), ".jplace")
    simulate_jplace_file(tips = i, place_nrow = j, file=file)
  }
}
