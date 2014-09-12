## 07/08/2014
## D.J. Bennett
## Model trees using EDBMM

## Libraries
source (file.path ('tools', 'model_tools.R'))

## Dirs
# create a unique dir based on time for every run
counter <- nrow (read.csv (runlog))
# create a tree filename
treefilename <- paste0 ('tree', counter, '.tre')
# record parameters in runlog
parameters <- data.frame (treefilename, strength, bias,
                          birth, death)
write.table (parameters, runlog, sep = ',', append = TRUE,
             col.names = FALSE, row.names = FALSE)

## Model
cat (paste0 ('\nModelling tree of size [', stop.at, '(',
             stop.by, ')] ...'))
# if seed is greater than 2
if (seed > 2) {
  # ... create a seed tree of 2-1
  seed.tree <- runEDBMM (birth = 2, death = 1,
                    stop.at = seed, stop.by = 'n',
                    strength = strength, bias = bias,
                    fossils = FALSE, record = FALSE)
  # reset names so no overlap
  seed.tree$tip.label <- paste0 ('t', 1:getSize (seed.tree))
  seed.tree$node.label <- paste0 ('n', 1:seed.tree$Nnode)
  tree <- runEDBMM (birth = birth, death = death,
                    stop.at = stop.at, stop.by = stop.by,
                    strength = strength, bias = bias,
                    fossils = FALSE, record = FALSE,
                    seed.tree = seed.tree)
} else {
  tree <- runEDBMM (birth = birth, death = death,
                    stop.at = stop.at, stop.by = stop.by,
                    strength = strength, bias = bias,
                    fossils = FALSE, record = FALSE)
}

## Saving results
cat ('\nSaving results ...')
write.tree (tree, file = file.path (res.dir, treefilename))