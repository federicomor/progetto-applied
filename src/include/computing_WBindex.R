#----A script to compute the scores----

computing_scoresWB <- function(pisa_data){
  library(dplyr)
  
  cat("***Recall to standardize your data***\n")
  pisa_data <- as.data.frame(scale(select_if(pisa_data,is.numeric)))
  
  psychologicalWB_var <- c("EUDMO","SWBP", "RESILIENCE")
  socialWB_var <- c("EMOSUPS","BELONG","BEINGBULLIED")
  
  load("SocialWB_loadings.RData")
  load("PsychologicalWB_loadings.RData")
  
  scores <- list()
  
  scores[["Social well-being"]] <- as.matrix(pisa_data[,socialWB_var]) %*% SocialWB 
  scores[["Psychological well-being"]] <- as.matrix(pisa_data[,psychologicalWB_var]) %*% PsychologicalWB
  
  return(scores)
}

