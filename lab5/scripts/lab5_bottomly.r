library(devtools)
library(Biobase)
library(sva)
library(bladderbatch)
library(broom)
library(tidyverse)
library(data.table)
library(gridExtra)
library(ggplot2)

#setwd("~/Documents/BIOINF/MCBS/lab5/lab5/scripts")

# Homework Problem 4:*
# Apply two different Linear Models to the Bottomly et al. data. 
# First, using a conventional approach, create a linear model with a genetic strain (biological variable) 
# and an experimental number (technical variable) on **uncorrected** gene expression data. 
# Second, create a linear model with a genetic strain (biological variables) on **corrected** gene expression
# data from ComBat. Make a scatter plots of coefficients and a histogram of p-values as done in this notebook. 
# Make sure that you are pulling out the correct coefficients, not any or all coefficients. 

pheno = pData(bottomly.eset)

# expression data
edata <- as.matrix(exprs(bottomly.eset))
#sumna <- apply(edata, 1, function(x) sum(is.na(x)))
edata <- edata[rowMeans(edata) > 10, ]
edata <- log2(as.matrix(edata) + 1)
edata <- t(scale(t(edata), scale=TRUE, center=TRUE))

uncorr_mod = lm(t(edata) ~ as.factor(pheno$strain) + as.factor(pheno$experiment.number))
uncorr_mod_tidy <- tidy(uncorr_mod)

combat_edata = ComBat(dat=edata, batch=pheno$experiment.number, mod=model.matrix(~1, data=pheno), par.prior=TRUE)

corr_mod = lm(t(combat_edata) ~ as.factor(pheno$strain))
corr_mod_tidy <- tidy(corr_mod)

# estimate scatterplots
est_compare <- tibble(
  LinearModel = uncorr_mod_tidy %>% filter(term == "as.factor(pheno$strain)DBA/2J") %>% select("estimate") %>% unlist,
  ComBat = corr_mod_tidy %>% filter(term == "as.factor(pheno$strain)DBA/2J") %>% select("estimate") %>% unlist)

ggplot(est_compare, aes(x=LinearModel, y=ComBat)) +
  geom_point(col="darkgrey", alpha=.5, size=.5) + geom_abline(intercept=0, slope=1, col="darkred") + geom_smooth(method = "lm", se = TRUE)  + theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Scatter Plot of Coefficients for Bottomly et al. Data")

ggsave(filename = "../figures/kukielka_problem4_estimates.png") 

# p-value histograms
png(filename="../figures/kukielka_problem4_pvalues.png", width=1000, height=500)

g1 <- ggplot(uncorr_mod_tidy %>% filter(term == "as.factor(pheno$strain)DBA/2J")) + geom_histogram(aes(x=estimate), bins = 100, fill="darkorange") + 
        ggtitle(label = "Uncorrected Gene Expressions") + theme(plot.title = element_text(hjust = 0.5))
g2 <- ggplot(corr_mod_tidy%>% filter(term == "as.factor(pheno$strain)DBA/2J")) + geom_histogram(aes(x=estimate), bins = 100, fill="darkorange") + 
        ggtitle(label = "ComBat Corrected Gene Expressions") + theme(plot.title = element_text(hjust = 0.5))

grid.arrange(g1, g2, ncol= 2, top="Linear Models for Bottomly et al. Data")
dev.off()

# Homework Problem 5:
# Apply ComBat and SVA to the Bottomly et al. data. Make a scatter plots of coefficients and a histogram of p-values, 
# comparing results based on ComBat and SVA. Assume that the biological variables in Bottomly et al data is the genetic 
# strains. Make sure that you are pulling out the correct coefficients/pvalues, not any or all of them.

strain = as.factor(pheno$strain)

mod = model.matrix(~strain,data=pheno)
mod0 = model.matrix(~1, data=pheno)
sva_output = sva(edata, mod, mod0, n.sv=num.sv(edata,mod, method="leek"))

modsva = lm(t(edata) ~ as.factor(pheno$strain) + sva_output$sv)
modsva_tidy <- tidy(modsva)

est_compare <- tibble(
  SVA = modsva_tidy %>% filter(term == "as.factor(pheno$strain)DBA/2J") %>% select("estimate") %>% unlist,
  ComBat = corr_mod_tidy %>% filter(term == "as.factor(pheno$strain)DBA/2J") %>% select("estimate") %>% unlist)

ge <- ggplot(est_compare, aes(x=SVA, y=ComBat)) +
  geom_point(col="darkgrey", alpha=.5, size=.5) + geom_abline(intercept=0, slope=1, col="darkred") + geom_smooth(method = "lm", se = TRUE)  + theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Scatter Plot of Coefficients for Bottomly et al. Data")

ggsave(filename = "../figures/kukielka_problem5_estimates.png", ge) 

# p-value histograms
png(filename="../figures/kukielka_problem5_pvalues.png", width=1000, height=500)

g1 <- ggplot(modsva_tidy %>% filter(term == "as.factor(pheno$strain)DBA/2J")) + geom_histogram(aes(x=estimate), bins = 100, fill="darkorange") + 
  ggtitle(label = "SVA") + theme(plot.title = element_text(hjust = 0.5))
g2 <- ggplot(corr_mod_tidy%>% filter(term == "as.factor(pheno$strain)DBA/2J")) + geom_histogram(aes(x=estimate), bins = 100, fill="darkorange") + 
  ggtitle(label = "ComBat") + theme(plot.title = element_text(hjust = 0.5))

grid.arrange(g1, g2, ncol= 2,
             top="Linear Models for Bottomly et al. Data")
dev.off()
