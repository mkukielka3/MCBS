
setwd("Documents/BIOINF/MCBS/lab3/lab3/scripts")

# Load libraries
library(devtools)
library(Biobase)
library(ggplot2)
library(RColorBrewer)
library(gplots)
library(tidyverse)
library(data.table)
library(corpcor)
library(irlba)
library(Rtsne)

# Load libraries

#con = url("http://bowtie-bio.sourceforge.net/recount/ExpressionSets/bottomly_eset.RData")
#load(file=con)
#close(con)
#save(bottomly.eset, file="../data/bottomly.Rdata")
load(file="../data/bottomly.Rdata")

# Prepare data
edata <- as.matrix(exprs(bottomly.eset))
edata <- edata[rowMeans(edata) > 10, ]
edata <- log2(as.matrix(edata) + 1)

edata_scaled <- t(scale(t(edata), scale=FALSE, center=TRUE))
svd.out <- svd(edata_scaled)

# Homework 1
# Make one heatmap of the aforementioned Bottomly data with the following options: 
# a) both rows and columns are clustered, 
# b) show a dendrogram only on the columns., 
# c) scale in the column direction.

my_palette <- colorRampPalette(c("blue", "white", "orange"))(n = 299)

png("../figures/kukielka_problem1.png",height=700,width=700)

heatmap.2(edata,
          main = "Bottomly et al. Clustered", # heat map title
          notecol="black",      # change font color of cell labels to black
          density.info="none",  # turns off density plot inside color legend
          trace="none",         # turns off trace lines inside the heat map
          margins =c(12,9),     # widens margins around plot
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="column",     # only draw a column dendrogram
          scale = "col",
          Colv = TRUE,
          Rowv = TRUE)

dev.off()

# Homework 2
# Explore different combinations of PCs in scatter plots while coloring the data points by the genetic strains. 
# Find a combination of PCs that separate the strains well. Send only one scatterplot.

PC = data.table(svd.out$v,pData(bottomly.eset))

# "commented out" plot generator
if (FALSE) {
  cols <- names(PC)[0:21]
  for (i in 1:20) {
    for (j in (i+1):21) {
      #png(paste("../figures/kukielka_problem2_",".png", sep=paste(i,j,sep="_")),height=700,width=700)
      print(paste(cols[i], cols[j], sep="-"))
      ggplot(PC) + geom_point(aes_string(x=cols[i], y=cols[j], col="strain"))
      
      ggsave(paste("../figures/kukielka_problem2_",".png", sep=paste(i,j,sep="_")))
      #dev.off()
    }
  }
}

ggplot(PC) + geom_point(aes(x=V2, y=V3, col=as.factor(strain))) #final
ggsave("../figures/kukielka_problem2.png")


# Homework 3: 
# Make a scatter plot of the top 2 left singular vectors.

png("../figures/kukielka_problem3.png",height=700,width=1400)

par(mfrow=c(1,2))
plot(1:nrow(edata), svd.out$u[,1],pch=20)
plot(1:nrow(edata), svd.out$u[,2],pch=20)

dev.off()


# Homework 4: 
# Make one figure that contains violin plots of the top 5 left singular vectors (loadings)

dt = data.table(svd.out$u[,1:5])
head(dt)
top5 <- gather(dt, singular_vector, value)
head(top5)
ggplot(top5)+ geom_violin(aes(x=as.factor(singular_vector), y=value),draw_quantiles = c(0.25, 0.5, 0.75)) + geom_jitter(aes(x=as.factor(singular_vector), y=value), alpha=0.5)
ggsave("../figures/kukielka_problem4.png")

# Homework 5
# Cluster the genes (rows) using K-means clustering (function `kmeans()`) on the original data, 
# with `k=5` clusters. Then, create a 2-dimensional t-SNE projection (as done previously) while 
# using the 5 clusters to color the data points corresponding to genes.

kmeans_clust <- kmeans(edata, 5)
clusters <- as.factor(kmeans_clust$cluster)

set.seed(1)

tsne_out <- Rtsne(edata, pca=TRUE, perplexity=30)
tsne = data.table(tsne_out$Y)
ggplot(tsne) + geom_point(aes(x=V1, y=V2, col=clusters))
ggsave("../figures/kukielka_problem5.png")
