# 16/07/2014
# D.J. Bennett
# Comparing simulated and empirical trees -- Interactive script

# LIBS
source (file.path ('tools', 'compare_tools.R'))
source (file.path ('tools', 'misc_tools.R'))
source (file.path ('tools', 'clade_tools.R'))
library (outliers)

# DIRS
data.dir <- file.path ('data', 'treestats')

# PARAMETERS
analysis.name <- 'analysis_5'
res.dir <- file.path ('results', analysis.name)
data.dir <- file.path ('data', 'treestats')
empirical.file <- 'min50_max500.Rd'

# INPUT
stats <- readIn (analysis.name)
extreme <- rbind (readIn ('Pan'), readIn ('Eph'),
                  readIn ('DE'), readIn ('PF'))
# load pre-calculated empirical tree stats -- real.stats and real.ed.values
load (file.path (data.dir, empirical.file))
# add taxoinfo to real.stats
taxoinfo <- read.csv (file.path (data.dir, 'taxoinfo.csv'),
                      stringsAsFactors=FALSE)
real.stats$phylum <- real.stats$class <- real.stats$order <- NA
taxoinfo <- taxoinfo[taxoinfo$treefile %in% real.stats$filename, ]
match.is <- match (taxoinfo$treefile, real.stats$filename)
real.stats$phylum[match.is] <- taxoinfo$phylum
real.stats$class[match.is] <- taxoinfo$class
real.stats$order[match.is] <- taxoinfo$order
real.stats$phylum[is.na (real.stats$phylum)] <- 'Unknown'
real.stats$class[is.na (real.stats$class)] <- 'Unknown'
real.stats$order[is.na (real.stats$order)] <- 'Unknown'
# read in clades
clade.stats <- readInCladeStats (stats, analysis.name)

# QUICK STATS
# how many tips?
mean (real.stats$ntaxa[real.stats$ntaxa <= 500], na.rm= TRUE)
sd (real.stats$ntaxa[real.stats$ntaxa <= 500], na.rm= TRUE)
# how many polys?
sum (real.stats$poly)
sum (real.stats$poly) *100 /nrow(real.stats)
# how many with bls?
sum (real.stats$bl)
sum (real.stats$bl) *100 /nrow(real.stats)
# when were they published?
mean (real.stats$date)
sd (real.stats$date)
# how many are ultrametric?
sum (real.stats$ul)
sum (real.stats$ul) * 100 / nrow (real.stats)
# how many were made ultrametric?
sum (real.stats$chronos)
sum (real.stats$chronos) * 100 / nrow (real.stats)
# how many suitable for gamma stats?
sum (real.stats$ul) + sum (real.stats$chronos)
# how many ..taxonomic..?
length (unique (real.stats$phylum)) - 1
length (unique (real.stats$class)) - 1
length (unique (real.stats$order)) - 1
sum (real.stats$phylum == 'Unknown' & real.stats$class == 'Unknown' &
       real.stats$order == 'Unknown')
unknowns <- which (real.stats$phylum == 'Unknown' & real.stats$class == 'Unknown' &
         real.stats$order == 'Unknown')
real.stats[unknowns, 'title']
# remove all values where gravity metrics shouldn't have been calclated
real.stats$gamma[!(real.stats$ul | real.stats$chronos)] <- NA
sum (!is.na (real.stats$gamma))  # should be about 469

# PARSE
# remove branch results where psv is greater than 1 -- this is impossible!
pull <- real.stats$psv > 1
sum (pull)  # 34 lost
real.stats$psv[pull] <- NA
real.stats$gamma[pull] <- NA
# Extremely conservative removal of outliers
cat ('\nDropping outliers ....')
real.stats <- dropOutliers (real.stats, 'sackin', signif=0.1^3)  # 11
hist (real.stats$sackin, main='Sackin')
real.stats <- dropOutliers (real.stats, 'colless', signif=0.1^3)  # 11
hist (real.stats$sackin, main='Colless')
real.stats <- dropOutliers (real.stats, 'gamma', signif=0.1^3)  # 0
hist (real.stats$gamma, main='Gamma')
real.stats <- dropOutliers (real.stats, 'psv', signif=0.1^3)  # 0
hist (real.stats$psv, main='PSV')

# TABLES
# S2
# colless
round (tapply (stats$colless, stats$scenario, mean, na.rm=TRUE), 2)
round (tapply (stats$colless, stats$scenario, sd, na.rm=TRUE) , 2)
round (tapply (extreme$colless, extreme$scenario, mean, na.rm=TRUE), 2)
round (tapply (extreme$colless, extreme$scenario, sd, na.rm=TRUE) , 2)
round (mean (real.stats$colless, na.rm=TRUE), 2)
round (sd (real.stats$colless, na.rm=TRUE), 2)
# sackin
round (tapply (stats$sackin, stats$scenario, mean, na.rm=TRUE), 2)
round (tapply (stats$sackin, stats$scenario, sd, na.rm=TRUE), 2)
round (tapply (extreme$sackin, extreme$scenario, mean, na.rm=TRUE), 2)
round (tapply (extreme$sackin, extreme$scenario, sd, na.rm=TRUE) , 2)
round (mean (real.stats$sackin, na.rm=TRUE), 2)
round (sd (real.stats$sackin, na.rm=TRUE), 2)
# gamma
res <- tapply (stats$gamma, stats$scenario, mean, na.rm=TRUE)
(res[1]*100/mean (res[2:4]))-100  # % lower DE gamma
t.test (x=stats$gamma[stats$scenario=='DE'],
        y=stats$gamma[stats$scenario!='DE'],
        alternative='less')
round (res, 2)
round (tapply (stats$gamma, stats$scenario, sd, na.rm=TRUE), 2)
tapply (real.stats$gamma, real.stats$ul | real.stats$chronos,
        mean, na.rm=TRUE)
tapply (real.stats$gamma, real.stats$ul | real.stats$chronos,
        sd, na.rm=TRUE)
real.res <- mean (real.stats$gamma, na.rm=TRUE)
(res[1]*100/real.res)-100  # % lower DE gamma
t.test (x=stats$gamma[stats$scenario=='DE'],
        y=real.stats$gamma,
        alternative='less')
round (tapply (extreme$gamma, extreme$scenario, mean, na.rm=TRUE), 2)
round (tapply (extreme$gamma, extreme$scenario, sd, na.rm=TRUE) , 2)
round (real.res, 2)
round (sd (real.stats$gamma, na.rm=TRUE), 2)
# PSV
round (tapply (stats$psv, stats$scenario, mean, na.rm=TRUE), 2)
round (tapply (stats$psv, stats$scenario, sd, na.rm=TRUE), 2)
round (tapply (extreme$psv, extreme$scenario, mean, na.rm=TRUE), 2)
round (tapply (extreme$psv, extreme$scenario, sd, na.rm=TRUE) , 2)
round (mean (real.stats$psv, na.rm=TRUE), 2)
round (sd (real.stats$psv, na.rm=TRUE), 2)
# age
res <- tapply (stats$age, stats$scenario, mean, na.rm=TRUE)
(res[1]*100/mean (res[2:4]))-100  # % lower DE age
t.test (x=stats$age[stats$scenario=='DE'],
        y=stats$age[stats$scenario!='DE'],
        alternative='less')
round (tapply (extreme$age, extreme$scenario, mean, na.rm=TRUE), 2)
round (tapply (extreme$age, extreme$scenario, sd, na.rm=TRUE) , 2)
round (res, 2)
round (tapply (stats$age, stats$scenario, sd, na.rm=TRUE), 2)

# Compare taxonomic groups
# increasing variance between taxonomic groups the lower the taxonomic rank
sackin.phylum <- tapply (real.stats$sackin, factor (real.stats$phylum), mean, na.rm=TRUE)
var (sackin.phylum)
sackin.class <- tapply (real.stats$sackin, factor (real.stats$class), mean, na.rm=TRUE)
var (sackin.class)
sackin.order <- tapply (real.stats$sackin, factor (real.stats$order), mean, na.rm=TRUE)
var (sackin.order)
psv.phylum <- tapply (real.stats$psv, factor (real.stats$phylum), mean, na.rm=TRUE)
var(psv.phylum, na.rm=TRUE)
psv.class <- tapply (real.stats$psv, factor (real.stats$class), mean, na.rm=TRUE)
var(psv.class, na.rm=TRUE)
psv.order <- tapply (real.stats$psv, factor (real.stats$order), mean, na.rm=TRUE)
var(psv.order, na.rm=TRUE)
# increase for both balance and gravity
var (sackin.order)*100/var (sackin.phylum)  # 232% increase in Sackin
var (psv.order, na.rm=TRUE)*100/var (psv.phylum, na.rm=TRUE)  # 127% increase in Sackin

# Table S3 -- Clade analysis
mean (clade.stats$cm, na.rm=TRUE)
sd (clade.stats$cm, na.rm=TRUE)
mean (clade.stats$cg, na.rm=TRUE)
sd (clade.stats$cg, na.rm=TRUE)
round (tapply (clade.stats$cm, clade.stats$scenario, mean, na.rm=TRUE), 4)
round (tapply (clade.stats$cm, clade.stats$scenario, sd, na.rm=TRUE), 4)
round (tapply (clade.stats$cg, clade.stats$scenario, mean, na.rm=TRUE), 4)
round (tapply (clade.stats$cg, clade.stats$scenario, sd, na.rm=TRUE), 4)
round (tapply (clade.stats$max.size, clade.stats$scenario, mean, na.rm=TRUE), 1)
round (tapply (clade.stats$max.size, clade.stats$scenario, sd, na.rm=TRUE), 1)
round (tapply (clade.stats$time.span, clade.stats$scenario, mean, na.rm=TRUE), 1)
round (tapply (clade.stats$time.span, clade.stats$scenario, sd, na.rm=TRUE), 1)
table (clade.stats$scenario)
# correlations
cor.test (clade.stats$tot.size, clade.stats$cm)
cor.test (clade.stats$tot.size, clade.stats$cg)
cor.test (clade.stats$cm, clade.stats$sig)
cor.test (clade.stats$cg, clade.stats$sig)
cor.test (clade.stats$cm, clade.stats$eps)
cor.test (clade.stats$cg, clade.stats$eps)

# FIGURES
# taxonomic
pdf (file.path (res.dir, 'taxonomic.pdf'), 14, 14)
# phyla
instances <- table (real.stats$phylum)
instances <- sort (instances, TRUE)
sum (instances[1:5]) * 100 / sum(instances)  # 85%
real.stats$phylum <- factor (real.stats$phylum, levels = names (instances))
p <- ggplot (real.stats, aes (factor (real.stats$phylum))) +
  geom_bar() + coord_flip() + xlab ('Phylum') + ylab ('N. trees') +
  theme_bw () + theme (text=element_text(size=25))
print (p)
ggBoxplot (real.stats, 'phylum', 'sackin', 'Sackin')
# t.test (x=real.stats$sackin[real.stats$phylum == 'Streptophyta'],
#         y=real.stats$sackin[real.stats$phylum == 'Ascomycota'])
ggBoxplot (real.stats, 'phylum', 'colless', 'Colless')
ggBoxplot (real.stats, 'phylum', 'gamma', expression(gamma))
ggBoxplot (real.stats, 'phylum', 'psv', 'PSV')
# class
instances <- table (real.stats$class)
instances <- sort (instances, TRUE)
ggBoxplot (real.stats, 'class', 'sackin', 'Sackin', 20)
ggBoxplot (real.stats, 'class', 'colless', 'Colless', 20)
ggBoxplot (real.stats, 'class', 'psv', 'PSV', 20)
ggBoxplot (real.stats, 'class', 'gamma', expression(gamma), 20)
# orders
ggBoxplot (real.stats, 'order', 'sackin', 'Sackin', 20)
ggBoxplot (real.stats, 'order', 'colless', 'Colless', 20)
ggBoxplot (real.stats, 'order', 'psv', 'PSV', 20)
ggBoxplot (real.stats, 'order', 'gamma', expression(gamma), 20)
# t.test (x=real.stats$gamma[real.stats$class == 'Actinopterygii'],
#         y=real.stats$gamma[real.stats$class == 'Aves'])
# ggBoxplot (real.stats[real.stats$phylum=='Streptophyta', ], 'class', 'psv', 'PSV', 5)
dev.off()
#real.stats[sample (1:nrow(real.stats), 10),c('title', 'phylum')]

# sanity check
stat.names <- c ("colless", "sackin", "psv", "gamma",
                 "age", "pd", 'ntaxa')
pdf(file.path (res.dir, 'sanity_checks.pdf'))
for (stat.name in stat.names) {
  hist (stats[, stat.name], xlab=stat.name, main='Simulated')
  hist (real.stats[, stat.name], xlab=stat.name, main='Empirical')
}
dev.off ()

# Z-scores for simulated trees
pdf (file.path (res.dir, 'tp.pdf'), width=8)
p <- tilePlot (stats, stats$colless, legend.title='Colless, Z-score')
print (p)
p <- tilePlot (stats, stats$sackin, legend.title='Sackin, Z-score')
print (p)
p <- tilePlot (stats, stats$gamma, legend.title='Gamma, Z-score')
print (p)
p <- tilePlot (stats, stats$psv, legend.title='PSV, Z-score')
print (p)
p <- tilePlot (stats, stats$age, legend.title='Age, Z-score')
print (p)
dev.off ()

# distances to real trees
pdf (file.path (res.dir, 'tp_dist_to_real.pdf'), width=8)
distances <- abs (stats$colless - mean (real.stats$colless, na.rm=TRUE))
p <- tilePlot (stats, distances, legend.title='Colless, Z-score')
print (p)
distances <- abs (stats$sackin - mean (real.stats$sackin, na.rm=TRUE))
p <- tilePlot (stats, distances, legend.title='Sackin, Z-score')
print (p)
distances <- abs (stats$gamma - mean (real.stats$gamma, na.rm=TRUE))
p <- tilePlot (stats, distances, legend.title='Gamma, Z-score')
print (p)
distances <- abs (stats$psv - mean (real.stats$psv, na.rm=TRUE))
p <- tilePlot (stats, distances, legend.title='PSV, Z-score')
print (p)
dev.off ()

# correlation between sig and imbalance
pdf (file.path (res.dir, 'corr_sig_balance.pdf'))
cor (stats$colless, stats$sig)
p <- ggplot (stats, aes (x=sig, y=colless))
p <- p + geom_point () + stat_smooth (method='lm') +
  ylab ('Colless') + xlab (expression (sigma)) +
  theme_bw ()
print (p)
cor (stats$sackin, stats$sig)
p <- ggplot (stats, aes (x=sig, y=sackin))
p <- p + geom_point () + stat_smooth (method='lm') +
  ylab ('Sackin') + xlab (expression (sigma)) +
  theme_bw ()
print (p)
dev.off ()

# Correlation between gravity and balance?
# probably due to part of the sample space missing -- low gravity + high imbalance
pull <- !is.na(real.stats$psv) & !is.na (real.stats$colless)
cor.test (real.stats$colless[pull], real.stats$psv[pull])
# plot (real.stats$colless~real.stats$psv)
# plot (stats$colless~stats$psv)
# real.stats[which (real.stats$psv > 0.95), ]
# cor.test (stats$colless, stats$psv)
pull <- stats$scenario == 'PF'
cor.test (stats$colless[pull], stats$psv[pull])
pull <- stats$scenario == 'DE'
cor.test (stats$colless[pull], stats$psv[pull])
pull <- stats$scenario == 'Pan'
cor.test (stats$colless[pull], stats$psv[pull])
pull <- stats$scenario == 'Eph'
cor.test (stats$colless[pull], stats$psv[pull])


# correlation between eps and gravity for simulations of negative sig
pdf (file.path (res.dir, 'corr_eps_gravity.pdf'))
cor (stats$psv[stats$sig < 0], stats$eps[stats$sig < 0])
p <- ggplot (stats[stats$sig < 0, ], aes (x=eps, y=psv))
p <- p + geom_point () + stat_smooth (method='lm') +
  ylab ('PSV') + xlab (expression (epsilon)) +
  theme_bw ()
print (p)
cor (stats$gamma[stats$sig < 0], stats$eps[stats$sig < 0])
p <- ggplot (stats[stats$sig < 0, ], aes (x=eps, y=gamma))
p <- p + geom_point () + stat_smooth (method='lm') +
  ylab (expression (gamma)) + xlab (expression (epsilon)) +
  theme_bw ()
print (p)
dev.off ()

# PCA
stat.names <- c ("colless", "sackin", "psv")
filtered <- filter (stats, grain=0.1)
pca (stats, real.stats, stat.names, 'pca.pdf',
     ignore.chronos=FALSE)
pca (filtered, real.stats, stat.names, 'pca_filtered.pdf',
     ignore.chronos=FALSE)
grains <- pca2 (stats, real.stats, stat.names, 'pca_grains.pdf',
                ignore.chronos=FALSE)

# Tiles of pca res
pdf (file.path (res.dir, 'tp_pca.pdf'))
real <- grains[nrow (grains), ]
sim <- grains[-nrow (grains), ]
d1 <- abs (real$pc1.mean - sim$pc1.mean)
d1 <- d1/max (d1)
d2 <- abs (real$pc2.mean - sim$pc2.mean)
d2 <- d2/max (d2)
sim$d <- d1 + d2
p <- ggplot (sim, aes (x=eps, y=sig)) + geom_tile (aes (fill=d)) +
  scale_fill_gradient2(low='red', mid='red', high='white', name='PC distance') +
  labs (x=expression (epsilon), y=expression (sigma)) +
  theme_bw() + theme (axis.title=element_text(size=25))
print (p)
dev.off()

# Looking at PCA of extreme scenarios only
stat.names <- c ("colless", "sackin", "psv")
pca (extreme, real.stats, stat.names, 'pca_extreme.pdf',
     ignore.chronos=FALSE)

# clade analysis
pdf (file.path (res.dir, 'clade_analysis.pdf'))
pull <- !is.na (clade.stats$cm)
p <- tilePlot (clade.stats[pull,], clade.stats$cm[pull], legend.title='CM, Z-score')
print (p)
pull <- !is.na (clade.stats$cg)
p <- tilePlot (clade.stats[pull,], clade.stats$cg[pull], legend.title='CG, Z-score')
print (p)

dev.off()
table (clade.stats$scenario)
tapply (clade.stats$max.size, clade.stats$scenario, mean)
tapply (clade.stats$max.size, clade.stats$scenario, sd)
tapply (clade.stats$time.span, clade.stats$scenario, mean)
tapply (clade.stats$time.span, clade.stats$scenario, sd)