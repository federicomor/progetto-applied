###########################################################
#                                                         #
#   t-SNE for High-Dimensional data visualization in R    #
#                                                         #
###########################################################

setwd("C:/PERSONAL/STAT APP 21-22/LABS/Lab 4 - Clustering/T-SNE")


# t-SNE is dimensionality reduction technique suitable for visualizing high dimensional datasets. 
# tSNE is an abbreviation of t-Distributed Stochastic Neighbor Embedding (t-SNE) and it was introduced by van der Maaten and Hinton.

# We won't go through the specific theoretical underpinnings of this method, but if you want a simple yet complete explanation of 
# how the algorithm works, you can check the following links:

# --> https://medium.com/swlh/t-sne-explained-math-and-intuition-94599ab164cf

# --> https://distill.pub/2016/misread-tsne/   (a nice platform for simulations where you can try t-SNE on complex non-linear data and change parameters)




###### QUALITATIVE INTUITION OF t-SNE Algorithm ##########


# 1: Let's consider x_i and x_j be two points in high dimensional space. 
#    The similarity of the data point x_i to that of x_j is given by the probability p(j|i) 
#    In simplistic terms, t-SNE models the probability of point x_j to be a neighbor of x_i 
#    (as a Gaussian distribution of the Euclidean distances in the original space).

# 2: Similarly, in lower dimensional space, we have counter parts of x_i and x_j as y_i and y_j respectively. 
#    We calculate their similarity probability as q(j|i), modeled as a t distribution (fatter tails spread the points more evenly)

# 3: For the two spaces to be similar, we need to have difference between p(j|i) and q(j|i) as zero. 
#    t-SNE tries to minimize the dissimilarity between these distributions (Kullback Divergences between the conditional probabilites).

# 4: The main parameter controlling the fitting is called perplexity. 
#    Perplexity is roughly equivalent to the number of nearest neighbors considered when matching the original and fitted distributions for each point. 
#    A low perplexity means we care about local scale and focus on the closest other points. High perplexity takes more of a "big picture" approach.


# In conclusion --> t-SNE learns a non-parametric mapping, which means that it does not learn an explicit function that maps data from the input space 
# to the map. Therefore, it is not possible to embed new data points in an existing map (although you could run t-SNE on the full dataset). 

# In contrast to, e.g., PCA, t-SNE has a non-convex objective function. 
# The objective function is minimized using a gradient descent optimization that is initiated randomly. 
# As a result, it is possible that different runs give you different solutions. 




## Installing the required package to run this notebook (uncomment line)
# install.packages("Rtsne")
# install.packages("tsne")
# install.packages("RSKC")

library(RSKC) # <- we need this to upload data

# NOTE: there are two libraries to perform t-SNE in R
library(tsne)
library(Rtsne)

help(tsne)
help(Rtsne) # <-- This library uses a faster more recent algorithm (Barnes-Hult) that is more efficient for large-scale data. 
            #     Today we will show this version that approximates t-sne. if you want the original algorithm in B-H implementation you should set theta=0.0



###### Learning t-SNE Plotting on Iris Dataset #######

# We will start by using a very simple and famous toy dataset: the IRIS dataset, that is available in R.

# The iris dataset contains four measurements (Sepal Length, Sepal Width, Petal Length, Petal Width) for 150 flowers 
# representing three species (Iris setosa, versicolor and virginica) of IRIS.

## Load dataset
IR <- iris # Loading the iris dataset into a object called IR
head(iris)


## Split IR into two objects: 1) containing measurements 2) containing species type
iris_data <- IR[ ,1:4] 
iris_species <- IR[ ,5] 


## Run the t-SNE algorithm and store the results into an object called tsne_results
tsne_results <- Rtsne(iris_data, perplexity=10, check_duplicates = FALSE, pca = FALSE, verbose=TRUE, traces=TRUE) # You can change the value of perplexity and see how the plot changes


## Generate the t_SNE plot
x11()
par(mfrow=c(1,2)) 
plot(tsne_results$Y, col = "blue", pch = 19, cex = 1.5) # Plotting the first image
plot(tsne_results$Y, col = "black", bg= iris_species, pch = 21, cex = 1.5) # Second plot: Color the plot by the real species type (bg= iris_species)



## Let's compare the t-sne plot results with what we would obtain through PCA

# multidimensional view (scatterplot-matrix)
x11()
plot(iris_data, col='black', bg=iris_species, main = 't-SNE plot of Iris data')

x11()
par(mfrow=c(1,2)) 
# PCA
pca_iris = princomp(iris_data, scores = T)$scores[,1:2]
plot(pca_iris, col = "black", bg=iris_species, pch = 21, cex = 1.5, main = 'PCA plot of Iris data')
# t-SNE
plot(tsne_results$Y, col = "black", bg=iris_species, pch = 21, cex = 1.5, main = 't-SNE plot of Iris data') 

# We cannot see a huge difference, since the dataset is low-dimensional and its clusters can be quite easily separated through linear methods.


# Just to grasp an intuition of how this algorithm works, let's have a look at what happens if we change the perplexity parameter.
# Again, if you do this experiment on much larger and complex datasets you will see much more significant differences between the plots.
perplex = c(1, 5, 10, 20, 30)
x11()
par(mfrow=c(1,5)) 
for(k in c(1:5)){
  
  tsne_results <- Rtsne(iris_data, perplexity=perplex[k], check_duplicates = FALSE, pca=FALSE)
  title = paste("Perplexity = ", perplex[k])
  plot(tsne_results$Y, col = "black", bg= iris_species, pch = 21, cex = 1, main = title)
  
}


#### t-SNE with high-dimensional real genomic data ####

# This is an example of representing datasets with extremely high dimensionality.
# We are dealing with gene expression in single-cell RNA sequencing. 
# The data is fake, but formatted as in real-life biology research. 
# We will upload two files, the first "Expression File" contain cells in rows and genes in columns, 
# the values represent the expression level of each gene.
# You can discriminate cell type according to the expression levels of some genes.

# This is a classical example of fully unsupervised analysis, since you do not know the cell types, 
# and you are trying to cluster similar points to infer them.
# I already did "the exercise" for you, and you can find the real cell-type names for each sample 
# in the "Meta-data file", so that we can color t-SNE representations.


expression_data <- read.table(file = "expression.csv", row.names = 1, sep=',', header = T) 
meta_data <- read.table(file = "meta.csv", row.names = 1, sep=',', header = T)

View(expression_data)

cell_type = as.factor(meta_data$cell_type)

# since t-SNE is an iterative algorithm it may take some time to run for very large datasets.
# For this reason, many times for visualization purposes it is recommended to run PCA first.
# The function in R has the pre-built option to perform PCA first, so now we will set this parameter to true

## Run the t-SNE algorithm
tsne_realData <- Rtsne(expression_data, perplexity=100, check_duplicates = FALSE, pca=TRUE)
## Generate the t_SNE plot
x11()
plot(tsne_realData$Y, col = "black", bg= cell_type, pch = 21, cex = 1, main = 't-SNE plot of gene expression data')

# Let's compare our results with pca analysis alone. You will see the algorithm takes the PCA inputs and "separates" the points more 
# to aid visualization. For example, now we can recognize the light-blue cluster that was scattered in the middle of the PCA plot.
x11()
par(mfrow=c(1,2)) 
# PCA
pca_genes = princomp(expression_data, scores = T)$scores[,1:2]
plot(pca_genes, col = "black", bg=cell_type, pch = 21, cex = 1, main = 'PCA')
plot(tsne_realData$Y, col = "black", bg= cell_type, pch = 21, cex = 1, main = 't-SNE')




####### PCA vs t-SNE on complex datasets: Optical Recognition of Handwritten Digits Data #########


# The dataset describes n = 1797 digits from 0 to 9 (K = 10), handwritten by 13 subjects. 
# Raw observations are 32x32 bitmaps, which are divided into nonoverlapping blocks of 4x4 and the 
# number of on pixels are counted in each block. 
# This generates p = 64 (= 8x8) variable, recording the normalized counts of pixels 
# in each block and each element is an integer in the range 0 to 16. 
# The row names of the matrix optd contains the true labels (between 0 and 9), and the column names of it contains the position 
# of the block in original bitmap.

# The optdigits dataset has 64 dimensions. Can t-SNE reduce these 64 dimensions to just 2 dimension while preserving structure in the process? 
# And will this structure (if present) allow handwritten digits to be correctly clustered together? Let's find out.


data("optd")

# We pick just a portion of our data to speed up the process
optd_ds <- optd[1:501,]

truedigit_labels = as.numeric(rownames(optd_ds))
trn <- data.matrix(optd_ds)

# We will perform both t-SNE and PCA analysis on our data, to check whether PCA alone can help in visualizing the clustering structure
tsne_optd <- Rtsne(trn, perplexity=20, check_duplicates = FALSE, pca=FALSE) # <- for better comparison we will set the PCA option to false in this case, but
                                                                            #    feel free to change this and check if results improve.
pca_optd = princomp(trn, scores = T)$scores[,1:2]

# Let's plot what we obtain
cols <- rainbow(10)

x11()
par(mfrow=c(1,2))
plot(tsne_optd$Y, t='n', main='Handwritten Digits t-SNE plot')
text(tsne_optd$Y, labels=truedigit_labels, col=cols[truedigit_labels +1])
plot(pca_optd, t='n', main='Handwritten Digits PCA plot')
text(pca_optd, labels=truedigit_labels, col=cols[truedigit_labels +1])




####### FINAL REMARKS #########

# Consider t-SNE as a dimensionality reduction tool mostly meant for VISUALIZATION purposes. 
# Because of the nature of the algorithm, we suggest you not to use it for inference or data transformation.

# 1. t-SNE plots are highly influenced by parameters. Thus it is necessary to perform t-SNE using different parameter values before analyzing results.
# 2. Since t-SNE is stochastic, each run may lead to slightly different output. This can be solved by fixing the value of random_state parameter 
#    for all the runs.
# 3. t-SNE doesn't retain the distance between clusters from the raw data. Distance between clusters might vary post dimensionality reduction in t-SNE. 
#    It is recommended not to obtain any conclusions solely from the distance between the clusters.
# 4. t-SNE shrinks widespread data and expands densely packed data. It is hence suggested not to decide the size and density/spread/variance 
#    of the clusters based on the output.
# 5. Lower perplexity values might result in fewer clusters. It is hence recommended to try various perplexity values ranging from 
#    2 to the number of data points to obtain better results.

