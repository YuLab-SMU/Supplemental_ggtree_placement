library(ggtree)
library(treeio)
library(tidytree)
library(jsonlite)

# Set working directory
setwd("./stimulated_data/")

# Define parameters
test_size <- 1000
tree_size <- 1000
options(digits=10)

# Generate a random tree and convert to tibble format
tree_1k <- ape::rtree(tree_size)
tbl <- as_tibble(tree_1k)

# Set random seed for reproducibility
set.seed(10)

# Create placement data with sampled values
place_1k <- data.frame(
  edge_num = sample(tbl$node, test_size, replace = TRUE),
  name = paste0("SQ", seq(1:test_size)),
  likelihood = rnorm(test_size, mean = 20, sd = 5),
  like_weight_ratio = rnorm(test_size, mean = 1, sd = 0.4),
  distal_length = rnorm(test_size, mean = 20, sd = 5),
  pendant_length = rnorm(test_size, mean = 20, sd = 5),
  node = sample(tbl$node, test_size, replace = TRUE)
)

# Process the data frame to generate a nested list
placements <- split(place_1k, place_1k$name)
placements <- lapply(placements, function(x) {
  p_values <- if (nrow(x) == 1) {
    as.vector(unlist(x[, c("edge_num", "likelihood", "like_weight_ratio", "distal_length", "pendant_length")]))
  } else {
    lapply(1:nrow(x), function(i) {
      as.vector(unlist(x[i, c("edge_num", "likelihood", "like_weight_ratio", "distal_length", "pendant_length")]))
    })
  }
  list(p = p_values, n = unique(x$name))
})

# Extract tree node information
tip_labels <- tree_1k$tip.label
node_branches <- tree_1k$edge.length
edges <- tree_1k$edge

# Obtain the original Newick format string
tree_str <- write.tree(tree_1k)

# Function to build extended Newick format with edge information
extend_newick_with_edges <- function(tree_str, edges, node_branches) {
  pattern <- ":(\\d+\\.\\d+)" # Pattern to match branch lengths
  
  # Replace branch lengths with edge numbers
  extended_tree_str <- tree_str
  for (i in 1:nrow(edges)) {
    branch_length <- sprintf("%.10f", node_branches[i])
    edge_num <- edges[i, 2]
    extended_tree_str <- gsub(
      sprintf(":%s", branch_length), 
      paste0(":", branch_length, "{", edge_num, "}"), 
      extended_tree_str, fixed = FALSE
    )
  }
  
  return(extended_tree_str)
}

# Generate extended Newick format string
extended_tree_str <- extend_newick_with_edges(tree_str, edges, node_branches)

# Create final JSON object
json_dat <- list(
  tree = extended_tree_str,
  placements = placements,
  metadata = list(info = "sample file, without any meaning"),
  version = 2,
  fields = c("edge_num", "likelihood", "like_weight_ratio", "distal_length", "pendant_length")
)

# Convert to JSON format and save to file
json_output <- toJSON(json_dat, pretty = TRUE, auto_unbox = TRUE)
# writeLines(json_output, con = "./test_jp_50k.jplace")

# Load jplace files and measure memory usage
library(peakRAM)
t1 <- peakRAM(test_jp <- read.jplace("./test_jp_1k.jplace"))
t2 <- peakRAM(test_jp <- read.jplace("./test_jp_10k.jplace"))
t3 <- peakRAM(test_jp <- read.jplace("./test_jp_50k.jplace"))
t4 <- peakRAM(test_jp <- read.jplace("./test_jp_100k.jplace"))

# Combine memory usage data and save to CSV
df <- rbind(t1, t2, t3, t4)
df$Tree_size <- c(1000, 10000, 50000, 100000)
write.csv(df, file = "./peakRAM_re.csv", row.names = FALSE)
