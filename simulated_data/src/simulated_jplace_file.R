extend_newick_with_edges <- function(tree, N) {
  tree <- write.tree(tree)
  p <- proto::proto(fun = function(this, x) paste0(x, "{", count,"}"))
  pattern <- "(:[0-9\\.eE\\+\\-]+)"

  extended_tree_str <- gsubfn::gsubfn(pattern,  p, tree)
  extended_tree_str <- paste0(gsub(";$","", extended_tree_str),"{", N,"};")
  return(extended_tree_str)
}

simulate_jplace_file <- function(tips=1000, 
                                 place_nrow=1000, 
                                 file=NULL
                        ){ 
  set.seed(123)
  tree <- ape::rtree(tips)
  nodes <- seq(tidytree::getNodeNum(tree))
  edge_nums <- sample(nodes, place_nrow, replace = TRUE, prob = NULL)
  tmp1 <- rnorm(place_nrow, mean=20, sd=5)
  tmp2 <- rnorm(place_nrow, mean=1, sd=0.4)

  place <- data.frame(edge_num=sample(nodes, place_nrow, replace = TRUE, prob = NULL),
             likelihood = tmp1,
             like_weight_ratio = tmp2,
             distal_length = tmp1,
             pendant_length = tmp1
           )

  tree <- extend_newick_with_edges(tree, max(nodes))
  placements <- pbapply::pblapply(seq(nrow(place)), function(i)list(p=unlist(unname(place[i,])), n=paste0('S',i)))

  json_data <- list(
               tree =  tree,
               placements = placements,
               metadata = list(info = "sample file, without any meaning"),
               version = 2,
               fields = c("edge_num", "likelihood", "like_weight_ratio", "distal_length", "pendant_length")
             )

  json_str <- toJSON(json_data, pretty = TRUE, auto_unbox = TRUE)
  if (is.null(file)){
    file <- paste0("simulate_tips", tips,"_placement_nrow_", place_nrow, ".jplace")
  }
  
  writeLines(json_str, con=file)
}
