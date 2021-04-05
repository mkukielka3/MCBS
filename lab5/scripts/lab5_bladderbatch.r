library(devtools)
library(Biobase)
library(sva)
library(broom)
library(tidyverse)
library(data.table)
library(gridExtra)
library(ggplot2)
library(gplots)
library(RColorBrewer)
library(gridExtra)

# sample info

library(bladderbatch)
pheno = pData(bladderEset)
# expression data
edata = exprs(bladderEset)

#sumna <- apply(edata, 1, function(x) sum(is.na(x)))
row.variances <- apply(edata, 1, function(x) var(x))
edata <- edata[row.variances < 6,]
edata.log <- log2(edata)
#edata <- scale(edata, scale=FALSE, center=TRUE)

# *Homework Problem 1:*
# Create a table to show the batch effects (refer to Figure 1 in Gilad and Mizrahi-Man, 2015). 
#There are 5 batches (`pheno$batch`); how are biological variables and other variables related to study design are 
# distributed among those 5 batches? Explain what could be a problem. Prepare this into a PDF file.

pdf(file = "../figures/kukielka_problem1.pdf", width=18, height=8)

batch = as.factor(pheno$batch)
g1 <- ggplot() + geom_histogram(data=pheno, aes_string("cancer"), stat="count") + 
        facet_wrap(~batch, nrow=1) + ylab(label = "Cancer") + xlab(label=" ")

g2 <- ggplot() + geom_histogram(data=pheno, aes_string("outcome"), stat="count") + 
        facet_wrap(~batch, nrow=1) + ylab(label = "Outcome") + xlab(label=" ")

text = paste("\nThe main problem here is that the variables are not equally distributed among the batches and as a result, the data that we get can be 'contaminated' ",
              "\nwith patterns unrelated to the biological signal of our interest. The histogrammes show that different types of bladder cancers are separated quite well",
              "\nwhen it comes to batches (mTCC is mainly in the 1t batch, mTCC-CIS in the 2nd and mTCC+CIS in the 3rd) and so we can imagine a situation in which the five",
              "\nbatches correspond to the days in which data was gathered or different rearchers resposible for gathering it.",
             "\nSuch variables greatly influence the results of our analysis and, if left unacccounted for, can lead to false biological conclusions.")

t<- ggplot() + annotate("text", x = 4, y = 25, size=5, label = text) + theme_void()

grid.arrange(g1, g2, t, nrow = 3, top = "Batch")
dev.off()


# Homework Problem 2:*
# Make heatmaps, BEFORE and AFTER cleaning the data using ComBat, where columns are arranged according to the 
# study design. You must sort the columns such that 5 batches are shown. Cluster the rows, but do not cluster 
# the columns (samples) when drawing a heatmap. The general idea is that you want to see if the Combat-cleaned data
# are any improvement in the general patterns.

#edata <- edata[1:4000,]

combat_edata = ComBat(dat=edata, batch=pheno$batch, mod=model.matrix(~1, data=pheno), par.prior=TRUE)

my_palette <- colorRampPalette(c("blue", "white", "darkred"))(n = 299)

ord <- data.frame(batch = pheno$batch, cols = colnames(edata))
ord <- ord[order(ord$batch),]

# NOTE: unfortunately I'm currently in the process of getting my computer fixed and as for now
# running this with all the rows crashed my R, hence the 7000 limitation
rows = 7500 
#rows = nrow(edata)

png("../figures/kukielka_problem2_1_before.png",height=700,width=700)
heatmap.2(edata[1:rows,ord$cols] ,
          main = "Bladder Cancer Data - Before ComBat", # heat map title
          notecol="black",      # change font color of cell labels to black
          density.info="none",  # turns off density plot inside color legend
          trace="none",         # turns off trace lines inside the heat map
          margins =c(12,9),     # widens margins around plot
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="row",     # only draw a row dendrogram
          labCol = ord$batch,
          scale = "row",
          Colv = FALSE)
dev.off()

png("../figures/kukielka_problem2_2_after.png",height=700,width=700)
heatmap.2(combat_edata[1:rows,ord$cols],
          main = "Bladder Cancer Data Cleaned by ComBat", # heat map title
          notecol="black",      # change font color of cell labels to black
          density.info="none",  # turns off density plot inside color legend
          trace="none",         # turns off trace lines inside the heat map
          margins =c(12,9),     # widens margins around plot
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="row",     # only draw a row dendrogram
          labCol = ord$batch,
          scale = "row",
          Colv = FALSE)
dev.off()

# *Homework Problem 3:*
# Make heatmaps of Pearson correlations statistics of samples. For example, see Figure 2 and 3 freom Gilad and 
# Mizrahi-Man (2015) F1000Research: \url{https://f1000research.com/articles/4-121}.
# First, compute the correlation statistics among columns. Second, create a heatmap using heatmap.2(). 
# Make sure to create or add labels for samples (cancer vs. normal; batch numbers; others)

corr_matrix <- cor(edata, method = 'pearson')

png("../figures/kukielka_problem3.png",height=700,width=700)

heatmap.2(corr_matrix,
          main = "Bladder Cancer Data Sample Correlation", # heat map title
          notecol="black",      # change font color of cell labels to black
          density.info="none",  # turns off density plot inside color legend
          trace="none",         # turns off trace lines inside the heat map
          margins =c(12,9),     # widens margins around plot
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="row",     # only draw a row dendrogram
          labCol = rev(pheno$outcome),
          labRow = pheno$cancer,
          xlab = "Outcome",
          ylab = "Cancer",
          revC = TRUE)

dev.off()
