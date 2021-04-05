# Lab 1 (1.03.21)
# Homework 1

library(GEOquery)
library(tidyverse)

data <- getGEO('GDS39', destdir = ".")
geneexp <- Table(data)[,-c(1,2)]
geneexp.df <- as.data.frame(lapply(geneexp, as.numeric))

#filter out rows with missing values
geneexp.num <- apply(geneexp.df, 2, as.numeric)
rows_missing <- apply(geneexp.num, 1, function(x) any(is.na(x)))

geneexp.clean <- geneexp.num[!rows_missing,]
paste("Numbers of rows after filtering:", nrow(geneexp.clean))

# scale and center rows
geneexp.complete <- as.data.frame(t(scale(t(geneexp.clean))))

#reshape data
geneexp.complete <- tibble::rownames_to_column(geneexp.complete, "rowid")
geneexp.tidy <- gather(geneexp.complete, key="Samples", value="GeneExp", -rowid)

#set as an ordered factor (for ggplot display)
geneexp.tidy$Samples <- factor(geneexp.tidy$Samples, levels = colnames(geneexp.complete))

#create heatmap
ggplot(data = geneexp.tidy, mapping = aes(Samples, rowid, fill = GeneExp))+
  geom_tile() +  scale_fill_gradient2(low="darkblue", mid='white',high="yellow", limits=c(-3,3)) + 
  ggtitle("Heatmap")+ theme(axis.text.x = element_text(angle = 60, vjust = 0.5, hjust=1),
  plot.title = element_text(hjust = 0.5)) + scale_y_discrete(labels = NULL, breaks = NULL) + labs(x = "", y = "") 

ggsave("./figures/kukielka_problem1.png")
