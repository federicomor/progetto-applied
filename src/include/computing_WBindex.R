#----A script to compute the scores----

computing_scoresWB <- function(pisa_data, root_proj_dir){
  library(dplyr)
  
  cat("***Recall to standardize your data***\n")
  pisa_data <- as.data.frame(scale(select_if(pisa_data,is.numeric)))
  
  psychologicalWB_var <- c("EUDMO","SWBP", "RESILIENCE")
  socialWB_var <- c("EMOSUPS","BELONG","BEINGBULLIED")
  
  load(paste(root_proj_dir,"/src/include/SocialWB_loadings.RData", sep=""))
  load(paste(root_proj_dir,"/src/include/PsychologicalWB_loadings.RData", sep=""))
  
  scores <- list()
  
  scores[["Social well-being"]] <- as.matrix(pisa_data[,socialWB_var]) %*% SocialWB 
  scores[["Psychological well-being"]] <- as.matrix(pisa_data[,psychologicalWB_var]) %*% PsychologicalWB
  
  return(scores)
}

